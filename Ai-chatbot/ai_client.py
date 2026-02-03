import os
import json
import re
import codecs
import time
from textblob import TextBlob
import google.generativeai as genai


# --- Utility Functions ---

def is_arabic(text: str) -> bool:
    """Return True if the text contains Arabic characters."""
    return bool(re.search(r"[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]", text))


def decode_unicode_escapes(s: str) -> str:
    """Decode literal Unicode escape sequences (e.g. "\\u0623\\u0647...") into characters.

    If the input is not a string or decoding fails, return the original value.
    """
    if not isinstance(s, str):
        return s

    def contains_arabic(text: str) -> bool:
        return bool(re.search(r"[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]", text))

    try:
        # Step 1: decode standard \uXXXX escapes
        t = codecs.decode(s, 'unicode_escape')
        if contains_arabic(t):
            return t
    except Exception:
        t = s

    # Step 2: sometimes UTF-8 bytes were escaped as \u00XX sequences and then
    # interpreted as latin-1 characters (e.g. \u00d8\u00a3 -> bytes D8 A3 -> Arabic).
    try:
        # Try latin-1 -> utf-8 once on the last decoded text
        try_bytes = t.encode('latin-1')
        decoded_once = try_bytes.decode('utf-8')
        if contains_arabic(decoded_once):
            return decoded_once
        # If not, attempt a few more recovery passes where strings like "Ã" and "Â"
        # indicate double-encoding. Iterate up to 3 times.
        cur = decoded_once
        for _ in range(3):
            if contains_arabic(cur):
                return cur
            try:
                cur = cur.encode('latin-1').decode('utf-8')
            except Exception:
                break
        if contains_arabic(cur):
            return cur
    except Exception:
        pass

    # Step 3: as a last resort, return the first pass result if it contains useful chars,
    # otherwise return original input
    if contains_arabic(t):
        return t

    return s


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

#def get_doctor_recommendation(symptom_text: str, db_path: str | None = None):
#    """Search the local doctors.db for a matching service keyword.
#
#    Returns a dict with keys name, specialty, services or None if no match.
#    The db_path defaults to the `doctors.db` located next to this module.
#    """
#    try:
#        if db_path is None:
#            db_path = os.path.join(os.path.dirname(__file__), 'doctors.db')
#        import sqlite3
#        conn = sqlite3.connect(db_path)
#        c = conn.cursor()
#        c.execute("SELECT name, specialty, services FROM doctors")
#        doctors = c.fetchall()
#        conn.close()
#        for name, specialty, services in doctors:
#            for keyword in services.split(","):
#                if keyword.strip() and keyword.strip().lower() in symptom_text.lower():
#                    return {"name": name, "specialty": specialty, "services": services}
#        return None
#    except Exception:
#        return None


# --- API Key Management Functions ---



def get_api_key(flag: int) -> str | None:
    """Get API key based on flag number.
    
    Args:
        flag: Key number (e.g., 1 for k1, 2 for k2, etc.)
        
    Returns:
        The API key value or None if not found
    """
    KEYS = {}
    KEYS_PATH = os.path.join(os.path.dirname(__file__), "vectoria.json")
    
    if os.path.isfile(KEYS_PATH):
        try:
            with open(KEYS_PATH, "r", encoding="utf-8") as f:
                KEYS = json.load(f)
        except json.JSONDecodeError as e:
            KEYS = {}
        except Exception as e:
            KEYS = {}
    else:
        KEYS = {}
    
    if flag:
        key_name = f"k{flag}"
        if key_name in KEYS:
            return KEYS[key_name]
    
    return None


def get_all_api_keys() -> list:
    """Get all API keys from vectoria.json.
    
    Returns:
        List of all API key values
    """
    KEYS = {}
    KEYS_PATH = os.path.join(os.path.dirname(__file__), "vectoria.json")
    
    if os.path.isfile(KEYS_PATH):
        try:
            with open(KEYS_PATH, "r", encoding="utf-8") as f:
                KEYS = json.load(f)
        except:
            KEYS = {}
    
    # Return all values from the JSON
    return list(KEYS.values()) if KEYS else []


class Thoutha:
    """Wrapper around Google Gemini API with automatic key rotation on 429 errors."""

    def __init__(self):
        if genai is None:
            raise ImportError("google.generativeai is not installed")

        self.current_key_index = 0
        self.classifier_model_name = os.getenv("GEMINI_CLASSIFIER_MODEL", "gemini-2.5-flash")
        self.chat_model_name = os.getenv("GEMINI_CHAT_MODEL", "gemini-2.5-flash")

        # Load API keys from vectoria.json first, then fall back to .env
        self._load_api_keys()
        self._configure_client()

    def _load_api_keys(self):
        """Load API keys from vectoria.json, fallback to .env variables."""
        # Try to load all keys from vectoria.json
        self.api_keys = get_all_api_keys()
        
        if not self.api_keys:
            # Fallback to environment variable
            single_key = os.getenv("GEMINI_API_KEY")
            if single_key:
                self.api_keys = [single_key]
                print("[Thoutha] Using backup key from .env")
            else:
                raise ValueError("No API keys found.")
        else:
            print(f"[Thoutha] Loaded {len(self.api_keys)} API key(s) from vectoria.json")



    def _configure_client(self):
        """Configure GenAI with the active key."""
        current_key = self.api_keys[self.current_key_index]
        # Mask key for logging
        masked_key = current_key[:4] + "..." + current_key[-4:]
        print(f"[Thoutha] Using API Key #{self.current_key_index + 1}: {masked_key}")

        genai.configure(api_key=current_key)
        self.classifier_model = genai.GenerativeModel(self.classifier_model_name)
        self.chat_model = genai.GenerativeModel(self.chat_model_name)

    def _rotate_key(self):
        """Switch to the next available API key."""
        if len(self.api_keys) <= 1:
            print("[Thoutha] Only 1 key available, cannot rotate.")
            return False

        self.current_key_index = (self.current_key_index + 1) % len(self.api_keys)
        print(f"[Thoutha] ⚠️ Quota hit. Rotating to Key #{self.current_key_index + 1}")
        self._configure_client()
        return True

    def _safe_generate(self, model, content, config=None):
        """
        Generic wrapper to retry generation across multiple keys.
        """
        max_attempts = len(self.api_keys)

        for attempt in range(max_attempts):
            # Show which key is being used for this request
            current_key = self.api_keys[self.current_key_index]
            masked_key = current_key[:4] + "..." + current_key[-4:]
            print(f"[Thoutha] 🔑 Using Key #{self.current_key_index + 1}: {masked_key}")
            
            try:
                if config:
                    result = model.generate_content(content, generation_config=config)
                else:
                    result = model.generate_content(content)
                
                # Success! Log which key handled the request
                print(f"[Thoutha] ✅ Request successful with Key #{self.current_key_index + 1}")
                return result

            except Exception as e:
                error_msg = str(e).lower()
                error_str = str(e)
                
                # Check exception type for more accurate detection
                exception_type = type(e).__name__
                
                # Print actual error for debugging (backend only)
                print(f"[Thoutha] Key #{self.current_key_index + 1} - Exception: {exception_type}")
                #print(f"[Thoutha] Error message: {error_str[:250]}")
                
                # More precise quota/rate limit detection
                # Check for ResourceExhausted exception type first
                is_resource_exhausted = exception_type == "ResourceExhausted"
                
                # Check for specific quota error patterns in message
                has_quota_keyword = (
                    "quota exceeded" in error_msg or
                    "resource_exhausted" in error_msg or
                    "generativelanguage.googleapis.com" in error_msg
                )
                
                # Check for HTTP 429 (Too Many Requests)
                has_429_code = "429" in error_str[:100]  # Check first 100 chars for status code
                
                # Check for explicit rate limit messages
                has_rate_limit = (
                    "rate limit" in error_msg or
                    "requests per" in error_msg or
                    "quota_metric" in error_str
                )
                
                # Determine if this is a quota error
                is_quota_error = is_resource_exhausted or (has_429_code and (has_quota_keyword or has_rate_limit))
                
                # Detect quota type
                is_per_minute = "perminute" in error_msg or "per minute" in error_msg
                is_per_day = "perday" in error_msg or "per day" in error_msg or "daily" in error_msg
                
                if is_quota_error:
                    quota_type = "per-minute" if is_per_minute else ("per-day" if is_per_day else "unknown")
                    print(f"[Thoutha] ⚠️  Key #{self.current_key_index + 1} quota exhausted ({quota_type} limit)")

                    # If this was the last attempt, all keys are exhausted - fail immediately
                    if attempt == max_attempts - 1:
                        print(f"[Thoutha] ❌ All {len(self.api_keys)} API keys exhausted ({quota_type} quota)")
                        raise RuntimeError(f"All API keys exhausted due to {quota_type} quota limit") from e

                    # Otherwise rotate and loop again
                    if self._rotate_key():
                        continue
                    else:
                        raise e  # Can't rotate
                else:
                    # If it's a different error (e.g. invalid input, auth error), fail immediately
                    print(f"[Thoutha] ⛔ Non-quota error detected: {exception_type}")
                    raise e

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
            response = self._safe_generate(self.classifier_model, prompt, generation_config)
            text = response.text if hasattr(response, 'text') else str(response)
            text = decode_unicode_escapes(text)
            return "YES" in text.upper()
        except Exception:
            return False

    # --- MAIN CHAT RESPONSE ---
    def generate_response(self, conversation_history: list) -> str:
        """Generate a conversational response from conversation history."""
        # Autocorrect last user input before generation
        if conversation_history and 'parts' in conversation_history[-1]:
            corrected = autocorrect_text(conversation_history[-1]['parts'][0])
            conversation_history[-1]['parts'][0] = corrected

        response = self._safe_generate(self.chat_model, conversation_history)
        text = response.text if hasattr(response, 'text') else str(response)
        text = decode_unicode_escapes(text)

        # --- Clean markdown formatting ---
        # Remove asterisks (*, **), underscores (_), and backticks (`) used by Gemini for bold/italic/code formatting
        text = re.sub(r'[\*_`]+', '', text)

        return text.strip()