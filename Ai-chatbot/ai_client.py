import re
import os
from dotenv import load_dotenv
from textblob import TextBlob  # For English spell correction

try:
    import google.generativeai as genai
except Exception:
    genai = None

# Load environment variables
load_dotenv()

# --- Utility Functions ---

def is_arabic(text: str) -> bool:
    """Return True if the text contains Arabic characters."""
    return bool(re.search(r"[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]", text))


def normalize_arabic(text: str) -> str:
    """Normalize Arabic text by removing diacritics and unifying characters."""
    # Remove tashkeel (harakat)
    text = re.sub(r'[\u0617-\u061A\u064B-\u0652]', '', text)
    # Unify Alif forms
    text = re.sub(r'[إأآا]', 'ا', text)
    # Replace dotless ya with dot ya
    text = re.sub(r'ى', 'ي', text)
    # Replace taa marbuta with haa
    text = re.sub(r'ة', 'ه', text)
    # Normalize spacing
    text = re.sub(r'\s+', ' ', text).strip()
    return text


def autocorrect_text(text: str) -> str:
    """Fix common spelling errors in English and normalize Arabic text."""
    try:
        if is_arabic(text):
            return normalize_arabic(text)
        else:
            corrected = str(TextBlob(text).correct())
            return corrected
    except Exception:
        return text


# --- Gemini Client Class ---

class Thoutha:
    """Wrapper around Google Gemini API for chat and classification."""

    def __init__(self, api_key: str = None, classifier_model: str = None, chat_model: str = None):
        if api_key is None:
            api_key = os.getenv("GEMINI_API_KEY")

        if not api_key:
            raise ValueError("api_key must be provided or set in GEMINI_API_KEY")

        if genai is None:
            raise ImportError("google.generativeai is not installed or failed to import")

        self.api_key = api_key
        genai.configure(api_key=api_key)
        # Allow overriding model names via constructor or environment variables.
        # Default to gemini-2.5-flash which supports generateContent for chat in v1beta.
        self.classifier_model_name = classifier_model or os.getenv("GEMINI_CLASSIFIER_MODEL", "gemini-2.5-flash")
        self.chat_model_name = chat_model or os.getenv("GEMINI_CHAT_MODEL", "gemini-2.5-flash")

        # Create GenerativeModel objects. If the specified model is invalid the
        # error will be raised when calling generate_content; we handle retries
        # there to allow a graceful fallback.
        self.classifier_model = genai.GenerativeModel(self.classifier_model_name)
        self.chat_model = genai.GenerativeModel(self.chat_model_name)

    # --- HYBRID DENTAL DETECTION ---
    def is_query_dental(self, user_query: str) -> bool:
        """Hybrid check: keyword-based detection + Gemini LLM fallback."""
        user_query = autocorrect_text(user_query)

        # --- Step 1: Keyword-based check (Arabic + English) ---
        dental_keywords = [
            # Arabic
            "سن", "اسنان", "ضرس", "ضروسي", "لثه", "فم", "طبيب اسنان", "خلع", "تسوس",
            "سنان", "وجع سن", "وجع ضرس", "سناني", "بتوجعني", "دكتور اسنان", "تلبيسه",
            "تبييض", "التقويم", "اللثه", "نزيف اللثه", "حشو", "ألم الضرس", "تقرح الفم",
            # English
            "tooth", "teeth", "gum", "dentist", "oral", "mouth", "toothache", "cavity",
            "bleeding gums", "wisdom tooth", "braces", "crown", "root canal", "fillings"
        ]

        normalized_query = user_query.lower().strip()

        # ✅ Quick keyword match
        for kw in dental_keywords:
            if kw in normalized_query:
                return True

        # --- Step 2: Gemini fallback if no keyword match ---
        prompt = f"""
        Is the following user query about dental health, dentistry, teeth, gums, or oral hygiene?
        Answer only with "YES" or "NO".

        Query: "{user_query}"
        """
        try:
            generation_config = genai.types.GenerationConfig(candidate_count=1, temperature=0.0)
            response = self.classifier_model.generate_content(prompt, generation_config=generation_config)
            return "YES" in response.text.upper()
        except Exception:
            # Model might not be available for this API version. Try a sensible
            # fallback once (gemini-2.5-flash), then give up.
            try:
                fallback = "gemini-2.5-flash"
                if self.classifier_model_name != fallback:
                    self.classifier_model = genai.GenerativeModel(fallback)
                    response = self.classifier_model.generate_content(prompt, generation_config=generation_config)
                    return "YES" in response.text.upper()
            except Exception:
                return False
            return False

    # --- MAIN CHAT RESPONSE ---
    def generate_response(self, conversation_history: list) -> str:
        """Generate a conversational response from conversation history."""
        try:
            # Autocorrect last user input before generation
            if conversation_history and 'parts' in conversation_history[-1]:
                corrected = autocorrect_text(conversation_history[-1]['parts'][0])
                conversation_history[-1]['parts'][0] = corrected

            response = self.chat_model.generate_content(conversation_history)
            return response.text.strip()
        except Exception as e:
            # If the configured chat model is not available, try a fallback model
            # once and re-raise a clearer error if that also fails.
            err_text = str(e).lower()
            if "not found" in err_text or "is not found" in err_text:
                try:
                    fallback = "gemini-2.5-flash"
                    if self.chat_model_name != fallback:
                        self.chat_model = genai.GenerativeModel(fallback)
                        response = self.chat_model.generate_content(conversation_history)
                        return response.text.strip()
                except Exception as e2:
                    raise RuntimeError(f"Error generating response (fallback failed): {e2}") from e2

            raise RuntimeError(f"Error generating response: {e}") from e
