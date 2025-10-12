import re
import traceback
import os
from dotenv import load_dotenv

try:
    import google.generativeai as genai
except Exception:  # pragma: no cover - import errors handled at runtime
    genai = None


load_dotenv()


def is_arabic(text: str) -> bool:
    """Return True if the text contains Arabic characters."""
    return bool(re.search(r"[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]", text))


class GeminiClient:
    """Light wrapper around google.generativeai to make generation callable from other scripts.

    Usage:
        client = GeminiClient(api_key)
        text = client.generate(prompt, model_name="gemini-2.5-flash")
    """

    def __init__(self, api_key: str = None):
        """Create a GeminiClient.

        If api_key is omitted, the constructor will try to read GEMINI_API_KEY
        from the environment (and will load a local .env file via python-dotenv).
        """
        if api_key is None:
            api_key = os.getenv("GEMINI_API_KEY")

        if not api_key:
            raise ValueError("api_key must be provided either as argument or via GEMINI_API_KEY environment variable")

        if genai is None:
            raise ImportError("google.generativeai is not installed or failed to import")

        self.api_key = api_key
        genai.configure(api_key=api_key)

    def generate(self, prompt: str, model_name: str = "gemini-2.5-flash") -> str:
        """Generate content using Gemini. Returns text on success, raises Exception on error.

        The function will attempt to read a .text attribute on the response; if not
        present it will return the stringified response.
        """
        try:
            model = genai.GenerativeModel(model_name)
            response = model.generate_content(prompt)
            if hasattr(response, "text"):
                return response.text.strip()
            return str(response).strip()
        except Exception:
            # keep traceback for caller
            raise
