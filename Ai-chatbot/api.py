"""Flask API wrapper for Thoutha (AI dental assistant).

This exposes a simple HTTP API so other websites can call the chatbot.

Endpoints:
- POST /chat  -> JSON { "message": "...", "session_id": "optional" }
    returns { "session_id": "...", "reply": "...", "doctor": {..} }
- GET /health -> { "status": "ok" }

Run with:
    python Ai-chatbot\flask_api.py

The API will load the Gemini API key using the same mechanism as `ai_client.Thoutha`.
"""
from __future__ import annotations
import os
import uuid
import traceback
from flask import Flask, request, jsonify, Response
import json

from dotenv import load_dotenv

load_dotenv()

# Also attempt to load a .env from the project root (one level up) in case the
# developer placed the .env next to the top-level README/requirements.
project_root = os.path.dirname(os.path.dirname(__file__))
root_env = os.path.join(project_root, '.env')
if os.path.exists(root_env):
    load_dotenv(root_env)

try:
    import ai_client
except Exception:
    # If imports fail, let the endpoints return an error message instead of crashing
    ai_client = None

app = Flask(__name__)
# Ensure Flask returns non-ASCII characters (e.g., Arabic) as-is in JSON responses
# instead of escaping them as \uXXXX sequences.
app.config['JSON_AS_ASCII'] = False

# Simple in-memory session store: session_id -> list of messages (dicts with role/content)
session_histories: dict[str, list[dict]] = {}


def get_doctor_recommendation(symptom_text: str):
    """Delegate to the shared ai_client.get_doctor_recommendation helper."""
    try:
        return ai_client.get_doctor_recommendation(symptom_text)
    except Exception:
        return None


# Initialize AI client (try at import time so we fail fast if API key is missing)
init_error = None
ai = None
if ai_client is not None:
    try:
        # Prefer explicit environment-supplied key, but pass it to the client
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            # also check common alternate name
            api_key = os.getenv('GEMINI_KEY')

        if api_key:
            ai = ai_client.Thoutha(api_key=api_key)
        else:
            # Try to initialize without key (the client will attempt to read env too),
            # but provide a clearer error message if it fails.
            try:
                ai = ai_client.Thoutha()
            except Exception as e:
                init_error = (
                    f"{e}.\n\nSet the GEMINI_API_KEY environment variable or place a .env file\n"
                    f"with GEMINI_API_KEY=your_key in either the Ai-chatbot folder or the project root.\n"
                    f"Example (PowerShell): $env:GEMINI_API_KEY = 'your_key_here'"
                )
    except Exception as e:
        init_error = str(e)


def make_json_response(obj, status=200):
    """Return a Flask Response with JSON encoded using ensure_ascii=False so
    non-ASCII (Arabic) characters are preserved in the HTTP response body.
    """
    return Response(json.dumps(obj, ensure_ascii=False), status=status, mimetype='application/json')


@app.after_request
def add_cors_headers(response):
    # Minimal CORS support for web clients during development. Adjust for production.
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    response.headers['Access-Control-Allow-Methods'] = 'GET,POST,OPTIONS'
    return response


@app.route('/health', methods=['GET'])
def health():
    return make_json_response({"status": "ok", "ai_initialized": init_error is None})


@app.route('/chat', methods=['POST'])
def chat():
    """Receive a user message and return the assistant reply.

    JSON body: { "message": "...", "session_id": "optional" }
    """
    if init_error is not None:
        return make_json_response({"error": "AI client failed to initialize", "details": init_error}, status=500)

    payload = request.get_json(force=True)
    if not payload or 'message' not in payload:
        return make_json_response({"error": "Missing 'message' in JSON body"}, status=400)

    message = payload['message']
    session_id = payload.get('session_id') or str(uuid.uuid4())

    # Ensure session exists
    history = session_histories.setdefault(session_id, [])
    history.append({"role": "user", "content": message})

    try:
        # language detection helper
        user_lang = 'ar' if ai_client.is_arabic(message) else 'en'

        # Hybrid dental relevance check
        is_dental = ai.is_query_dental(message)
        if not is_dental:
            if user_lang == 'ar':
                refusal = "عذراً، يمكنني فقط الإجابة على الأسئلة المتعلقة بصحة الأسنان والفم."
            else:
                refusal = "I can only answer questions about dental and oral health."
            # append assistant refusal to history
            history.append({"role": "assistant", "content": refusal})
            return make_json_response({"session_id": session_id, "reply": refusal})

        # Build conversation_for_api similar to the streamlit app
        if user_lang == 'ar':
            system_prompt = (
                "أنت 'ثوثة'، مساعد ذكاء اصطناعي متخصص في طب الأسنان. دورك هو مناقشة الأعراض وطرح أسئلة توضيحية. "
                "يجب أن ترفض بأدب الإجابة على أي أسئلة غير متعلقة بالأسنان. لا تقدم تشخيصًا طبيًا نهائيًا أبدًا. "
                "هدفك هو تشجيع المستخدم على استشارة طبيب أسنان بشري."
            )
        else:
            system_prompt = (
                "You are 'Thoutha', a specialized dental AI assistant. Your role is to discuss symptoms and ask clarifying questions. "
                "You must politely refuse to answer any non-dental questions. Never provide a definitive medical diagnosis. "
                "Your goal is to encourage the user to consult a human dentist."
            )

        conversation_for_api = [
            {'role': 'user', 'parts': [system_prompt]},
            {'role': 'model', 'parts': ["Understood. I am Thoutha, ready to assist with dental inquiries."]}
        ]
        for msg in history:
            role = 'user' if msg['role'] == 'user' else 'model'
            conversation_for_api.append({'role': role, 'parts': [msg['content']]})

        diagnosis_text = ai.generate_response(conversation_for_api)

        # Ensure any unicode-escape sequences are decoded (tolerant) and return
        # actual Unicode characters to clients.
        try:
            reply = ai_client.decode_unicode_escapes(diagnosis_text)
        except Exception:
            reply = diagnosis_text

        doctor = get_doctor_recommendation(message + ' ' + diagnosis_text)
        # Decode doctor fields as well if present
        if doctor:
            try:
                doctor['name'] = ai_client.decode_unicode_escapes(doctor.get('name', ''))
                doctor['specialty'] = ai_client.decode_unicode_escapes(doctor.get('specialty', ''))
                doctor['services'] = ai_client.decode_unicode_escapes(doctor.get('services', ''))
            except Exception:
                pass
        if doctor:
            # include doctor info in response
            return make_json_response({
                "session_id": session_id,
                "reply": reply,
                "doctor": doctor
            })

        # append assistant message to history and return
        history.append({"role": "assistant", "content": reply})
        return make_json_response({"session_id": session_id, "reply": reply})

    except Exception as e:
        tb = traceback.format_exc()
        return make_json_response({"error": "internal_error", "details": str(e), "trace": tb}, status=500)


if __name__ == '__main__':
    # Run using: python Ai-chatbot\flask_api.py
    app.run(host='0.0.0.0', port=5000, debug=False)
