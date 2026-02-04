"""
Endpoints:
- POST /api/session/start -> Start new session with language selection
- POST /api/session/answer -> Process answer and determine next step
- POST /api/chat -> Chat with AI bot (used after triggering chatbot mode)
- GET /api/session/<session_id> -> Get session details
- GET /health -> Health check
"""

from flask import Flask, request, jsonify, Response
from flask_cors import CORS
from uuid import uuid4
from datetime import datetime
import os
import json
import uuid
import traceback
from dotenv import load_dotenv

load_dotenv()

# Try to import AI client
try:
    import ai_client
except Exception as e:
    print(f"[RULE_BOT] Failed to import ai_client: {e}")
    traceback.print_exc()
    ai_client = None

app = Flask(__name__)
CORS(app)
app.config['JSON_AS_ASCII'] = False

# ==================== RULE-BASED SYSTEM CONFIGURATION ====================

# Load questions from external JSON
QUESTIONS = {}
QUESTIONS_PATH = os.path.join(os.path.dirname(__file__), "questions.json")
if os.path.isfile(QUESTIONS_PATH):
    try:
        with open(QUESTIONS_PATH, "r", encoding="utf-8") as f:
            QUESTIONS = json.load(f)
    except Exception as e:
        print(f"Failed to load questions.json: {e}")
        QUESTIONS = {}
else:
    QUESTIONS = {}

# Deterministic transitions
TRANSITIONS = {
    "Q1": {
        "A": {"next": "Q2A"},
        "B": {"next": "Q2B"},
        "C": {"next": "Q2C"},
        "D": {"next": "Q2D"},
        "E": {"category": "Comprehensive Dental Examination"},
        "F": {"next": "Q2F"},
        "G": {"chatbot": True}  # Trigger chatbot mode for "Something else"
    },
    "Q2A": {
        "A1": {"category": "Teeth Whitening"},
        "A2": {"category": "Dental Crowns / Prosthodontics"}
    },
    "Q2B": {
        "B1": {"next": "Q3B"},
        "B2": {"category": "Tooth Extraction"}
    },
    "Q3B": {
        "B1a": {"category": "Dental Fillings"},
        "B1b": {"category": "Comprehensive Dental Examination"}
    },
    "Q2C": {
        "C1": {"category": "Orthodontics"},
        "C2": {"category": "Orthodontics"}
    },
    "Q2D": {
        "D1": {"category": "Dental Implants"},
        "D2": {"category": "Dental Crowns / Prosthodontics"}
    },
    "Q2F": {
        "F1": {"category": "Dental Crowns / Prosthodontics"},
        "F2": {"category": "Dental Fillings"},
        "F3": {"category": "Tooth Extraction"}
    },
    "Q2G": {
        "G1": {"category": "Teeth Whitening"},
        "G2": {"category": "Tooth Extraction"},
        "G3": {"category": "Orthodontics"},
        "G4": {"category": "Dental Implants"},
        "G5": {"category": "Comprehensive Dental Examination"}
    }
}

# Allowed final categories
CATEGORIES = [
    "Teeth Whitening",
    "Dental Crowns / Prosthodontics",
    "Orthodontics",
    "Dental Fillings",
    "Tooth Extraction",
    "Comprehensive Dental Examination",
    "Dental Implants"
]

# Category translations
CATEGORY_TRANSLATIONS = {
    "Teeth Whitening": {"en": "Teeth Whitening", "ar": "تبييض الأسنان"},
    "Dental Crowns / Prosthodontics": {"en": "Dental Crowns / Prosthodontics", "ar": "تيجان الأسنان / التركيبات"},
    "Orthodontics": {"en": "Orthodontics", "ar": "تقويم الأسنان"},
    "Dental Fillings": {"en": "Dental Fillings", "ar": "حشوات الأسنان"},
    "Tooth Extraction": {"en": "Tooth Extraction", "ar": "خلع الأسنان"},
    "Comprehensive Dental Examination": {"en": "Comprehensive Dental Examination", "ar": "فحص شامل للأسنان"},
    "Dental Implants": {"en": "Dental Implants", "ar": "زراعة الأسنان"}
}

def validate_transitions():
    """Validate that TRANSITIONS reference existing questions/options and allowed categories."""
    errors = []
    # Ensure QUESTIONS loaded
    if not QUESTIONS:
        errors.append("QUESTIONS is empty or failed to load questions.json")

    for qid, rules in TRANSITIONS.items():
        if qid not in QUESTIONS:
            errors.append(f"TRANSITIONS references unknown question id: {qid}")
            continue
        # collect valid option ids for the question
        q_opts = {opt["id"] for opt in QUESTIONS[qid].get("options", [])}
        for aid, outcome in rules.items():
            if aid not in q_opts:
                errors.append(f"Transition for question {qid} references unknown answer id: {aid}")
            if "next" in outcome:
                nxt = outcome["next"]
                if nxt not in QUESTIONS:
                    errors.append(f"Transition {qid}->{aid} next references unknown question: {nxt}")
            if "category" in outcome:
                cat = outcome["category"]
                if cat not in CATEGORIES:
                    errors.append(f"Transition {qid}->{aid} uses unknown category: {cat}")

    if errors:
        print("Configuration validation failed with the following errors:")
        for e in errors:
            print(" - ", e)
        import sys
        sys.exit(1)

# Run validation at startup
if QUESTIONS:
    validate_transitions()

# ==================== AI CHATBOT CONFIGURATION ====================

# In-memory session stores
SESSIONS = {}  # Rule-based sessions
session_histories = {}  # AI chat histories

# Initialize AI client
init_error = None
ai = None
if ai_client is not None:
    try:
        ai = ai_client.Thoutha()
    except Exception as e:
        init_error = str(e)
        print(f"[RULE_BOT] Failed to initialize AI: {e}")

# ==================== HELPER FUNCTIONS ====================

def now_iso():
    return datetime.utcnow().isoformat() + "Z"

def get_localized_category(category, language):
    """Return category name in specified language (en or ar)."""
    if category not in CATEGORY_TRANSLATIONS:
        return category
    lang = language if language in ("en", "ar") else "en"
    return CATEGORY_TRANSLATIONS[category].get(lang, category)

def localized_question(qid, language):
    """Return question and options localized to language ('en' or 'ar')."""
    q = QUESTIONS.get(qid)
    if not q:
        return None
    lang = language if language in ("en", "ar") else "en"
    
    # Special-case: language selection question
    if qid == "Q0" and language is None:
        text = q.get("text_en") or q.get("text_ar") or q.get("text")
        opts = []
        for o in q.get("options", []):
            e = o.get("text_en") or o.get("text")
            a = o.get("text_ar") or o.get("text")
            opts.append({"id": o["id"], "text": f"{e} / {a}"})
        return {"id": q["id"], "text": text, "options": opts}

    text = q.get(f"text_{lang}") or q.get("text_en") or q.get("text")
    opts = []
    for o in q.get("options", []):
        otext = o.get(f"text_{lang}") or o.get("text_en") or o.get("text")
        opts.append({"id": o["id"], "text": otext})
    return {"id": q["id"], "text": text, "options": opts}

def record_answer(session, question_id, answer_id):
    session["answers"].append({
        "question_id": question_id,
        "answer_id": answer_id,
        "timestamp": now_iso()
    })

def decision_path_reason(session):
    parts = []
    for a in session["answers"]:
        q = a["question_id"]
        ans = a["answer_id"]
        parts.append(f"{q}={ans}")
    return " -> ".join(parts)

def evaluate_answers(answers):
    """Evaluate a list of answers (list of {question_id, answer_id}) and
    return (category, reason) if determinable, otherwise (None, next_question_id, path)
    """
    path = []
    current_q = None
    # skip language Q0 answers if present
    for a in answers:
        if a.get("question_id") == "Q0":
            continue
        current_q = a.get("question_id")
        aid = a.get("answer_id")
        path.append(f"{current_q}={aid}")
        trans = TRANSITIONS.get(current_q, {})
        outcome = trans.get(aid)
        if not outcome:
            return ("Comprehensive Dental Examination", " -> ".join(path) + " -> default")
        if "category" in outcome:
            return (outcome["category"], " -> ".join(path))
        if "next" in outcome:
            # continue to next; ensure next matches next answer if provided
            next_q = outcome["next"]
            # look ahead: if next answer exists and matches next_q, loop will handle it
            current_q = next_q
            continue

    # no decisive category found
    return (None, current_q, " -> ".join(path))

def make_json_response(obj, status=200):
    """Return a Flask Response with JSON encoded with ensure_ascii=False."""
    return Response(json.dumps(obj, ensure_ascii=False), status=status, mimetype='application/json')

@app.after_request
def add_cors_headers(response):
    """Add CORS headers for web clients during development."""
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    response.headers['Access-Control-Allow-Methods'] = 'GET,POST,OPTIONS'
    return response

# ==================== API ENDPOINTS ====================

@app.route('/health', methods=['GET'])
def health():
    return make_json_response({
        "status": "ok",
        "ai_initialized": init_error is None,
        "questions_loaded": len(QUESTIONS) > 0
    })

@app.route("/api/resolve", methods=["POST"])
def resolve():
    """Resolve category from a provided answer sequence without creating a session.
    Request: { "answers": [ {"question_id":"Q1","answer_id":"C"}, ... ], "language": "en" }
    Response: { "category": "Orthodontics", "reason": "Q1=C -> Q2C=C2" }
    """
    payload = request.get_json(force=True)
    answers = payload.get("answers") or []
    if not isinstance(answers, list) or len(answers) == 0:
        return jsonify({"error": "answers (non-empty list) required"}), 400

    res = evaluate_answers(answers)
    if res[0]:
        # resolved
        return jsonify({"category": res[0], "reason": res[1]})
    else:
        # not resolved; return next question id and current path
        next_q = res[1]
        path = res[2]
        qobj = localized_question(next_q, payload.get("language")) if next_q else None
        return jsonify({"category": None, "next_question": qobj, "reason": path})

@app.route("/api/session/start", methods=["POST"])
def start_session():
    """Start a new session with language selection."""
    session_id = str(uuid4())
    session = {
        "session_id": session_id,
        "created_at": now_iso(),
        "current_question_id": "Q0",
        "answers": [],
        "resolved": False,
        "category": None,
        "reason": None,
        "language": None,
        "chatbot_mode": False  # New flag to track if in chatbot mode
    }
    SESSIONS[session_id] = session
    return jsonify({
        "session_id": session_id,
        "question": localized_question("Q0", None),
        "session": session
    })

@app.route("/api/session/answer", methods=["POST"])
def answer():
    """Process an answer and determine next step (question, category, or chatbot)."""
    payload = request.get_json(force=True)
    session_id = payload.get("session_id")
    question_id = payload.get("question_id")
    answer_id = payload.get("answer_id")

    if not session_id or not question_id or not answer_id:
        return jsonify({"error": "session_id, question_id and answer_id required"}), 400

    session = SESSIONS.get(session_id)
    if not session:
        return jsonify({"error": "session not found"}), 404

    if session["resolved"]:
        return jsonify({"error": "session already resolved", "session": session}), 400

    if session["current_question_id"] != question_id:
        return jsonify({
            "error": "question_id does not match current session question",
            "current_question_id": session["current_question_id"]
        }), 400

    # Validate answer exists for question
    q = QUESTIONS.get(question_id)
    if not q:
        return jsonify({"error": "invalid question_id"}), 400
    valid_ids = [opt["id"] for opt in q["options"]]
    if answer_id not in valid_ids:
        return jsonify({"error": "invalid answer_id for question", "valid_options": valid_ids}), 400

    # Record answer
    record_answer(session, question_id, answer_id)

    # Special handling for language selection (Q0)
    if question_id == "Q0":
        aid = answer_id.upper()
        lang = "ar" if aid == "AR" else "en"
        session["language"] = lang
        session["current_question_id"] = "Q1"
        return jsonify({"question": localized_question("Q1", lang), "session": session})

    # Determine transition
    trans = TRANSITIONS.get(question_id, {})
    outcome = trans.get(answer_id)
    
    if not outcome:
        # No transition found, default to Comprehensive Dental Examination
        session["resolved"] = True
        session["category"] = "Comprehensive Dental Examination"
        session["reason"] = decision_path_reason(session) + " -> default"
        localized_cat = get_localized_category(session["category"], session.get("language"))
        return jsonify({
            "result": {
                "category": localized_cat,
                "category_en": session["category"],
                "reason": session["reason"]
            },
            "session": session
        })

    # Check if outcome triggers chatbot mode
    if outcome.get("chatbot"):
        session["chatbot_mode"] = True
        session["resolved"] = True  # Mark as resolved from rule-based perspective
        lang = session.get("language", "en")
        
        if lang == "ar":
            chat_message = "تم تفعيل وضع الدردشة. يمكنك الآن التحدث معي عن أي مشكلة أسنان."
        else:
            chat_message = "Chat mode activated. You can now talk to me about any dental issue."
        
        # Initialize chat history for this session
        session_histories[session_id] = []
        
        return jsonify({
            "chatbot_activated": True,
            "message": chat_message,
            "session": session
        })

    # Check if outcome is a category
    if "category" in outcome:
        session["resolved"] = True
        session["category"] = outcome["category"]
        session["reason"] = decision_path_reason(session)
        session["current_question_id"] = None
        localized_cat = get_localized_category(session["category"], session.get("language"))
        return jsonify({
            "result": {
                "category": localized_cat,
                "category_en": session["category"],
                "reason": session["reason"]
            },
            "session": session
        })

    # Check if outcome points to next question
    if "next" in outcome:
        next_q = outcome["next"]
        session["current_question_id"] = next_q
        
        # Safety: if follow-ups exceed threshold, default to comprehensive exam
        if len(session["answers"]) >= 4 and not session["resolved"]:
            session["resolved"] = True
            session["category"] = "Comprehensive Dental Examination"
            session["reason"] = decision_path_reason(session) + " -> fallback after max follow-ups"
            localized_cat = get_localized_category(session["category"], session.get("language"))
            return jsonify({
                "result": {
                    "category": localized_cat,
                    "category_en": session["category"],
                    "reason": session["reason"]
                },
                "session": session
            })

        # Return next question localized to chosen language
        return jsonify({"question": localized_question(next_q, session.get("language")), "session": session})

    # Unknown outcome structure
    session["resolved"] = True
    session["category"] = "Comprehensive Dental Examination"
    session["reason"] = decision_path_reason(session) + " -> unknown outcome"
    localized_cat = get_localized_category(session["category"], session.get("language"))
    return jsonify({
        "result": {
            "category": localized_cat,
            "category_en": session["category"],
            "reason": session["reason"]
        },
        "session": session
    })

@app.route('/api/chat', methods=['POST'])
def chat():
    """Chat with AI bot (used after chatbot mode is activated)."""
    if init_error is not None:
        return make_json_response({
            "error": "AI client failed to initialize",
            "details": init_error
        }, status=500)

    payload = request.get_json(force=True)
    if not payload or 'message' not in payload:
        return make_json_response({"error": "Missing 'message' in JSON body"}, status=400)

    message = payload['message']
    session_id = payload.get('session_id') or str(uuid.uuid4())

    # Check if ai_client module loaded successfully
    if ai_client is None:
        return make_json_response({
            "error": "AI client module failed to import",
            "details": "Check server logs for import errors"
        }, status=500)

    # Get session to determine language
    session = SESSIONS.get(session_id)
    user_lang = session.get("language", "en") if session else "en"
    
    # Override with detected language if Arabic is detected
    if ai_client.is_arabic(message):
        user_lang = 'ar'

    # Ensure session history exists
    history = session_histories.setdefault(session_id, [])
    history.append({"role": "user", "content": message})

    try:
        # Build conversation for API
        
        if user_lang == 'ar':
            categories_list = [CATEGORY_TRANSLATIONS.get(c, {}).get('ar', c) for c in CATEGORIES]
            categories_str = ", ".join(categories_list)
            system_prompt = (
                "أنت 'ثوثة'، مساعد ذكاء اصطناعي دكتور سنان. اتكلم باللهجة المصرية العامية. "
                "دورك انك تتناقش مع المستخدم في الأعراض وتسأل أسئلة عشان تشخص الحالة. "
                "أول حاجة، قيم لو سؤال المستخدم ليه علاقة بصحة الأسنان أو الفم. "
                "لو ملوش علاقة، رد بكلمة واحدة بس: 'REFUSAL_NON_DENTAL'. "
                "لو ليه علاقة، كمل واسأل عن الأعراض. "
                "هدفك انك تفهم المشكلة وتوجه المستخدم لواحد من التصنيفات دي: "
                f"[{categories_str}]. "
                "اسأل أسئلة قصيرة ومباشرة عشان تجمع معلومات. لما تكون متأكد من التصنيف، قوله بوضوح في إجابتك."
            )
        else:
            categories_str = ", ".join(CATEGORIES)
            system_prompt = (
                "You are 'Thoutha', a specialized dental AI assistant. Your role is to discuss symptoms and ask clarifying questions to triage the user. "
                "First, evaluate if the user's query is related to dental or oral health. "
                "If it is NOT related, reply with exactly: 'REFUSAL_NON_DENTAL'. "
                "If it IS related, proceed to discuss symptoms and triage the user. "
                "Your goal is to understand the user's issue and guide them towards one of the following categories: "
                f"[{categories_str}]. "
                "Ask short, direct questions to gather information. When you are confident in a category, mention it clearly in your response."
            )

        conversation_for_api = [
            {'role': 'user', 'parts': [system_prompt]},
            {'role': 'model', 'parts': ["Understood. I am Thoutha, ready to assist with dental inquiries and triage."]}
        ]
        
        for msg in history:
            role = 'user' if msg['role'] == 'user' else 'model'
            conversation_for_api.append({'role': role, 'parts': [msg['content']]})

        diagnosis_text = ai.generate_response(conversation_for_api)

        # Check for refusal flag from AI
        # Normalize text to handle variations like REFUSALNONDENTAL or Refusal_Non_Dental
        # We check if the flag exists (ignoring case/underscores) AND the response is short
        clean_text = diagnosis_text.upper().replace("_", "").replace(" ", "").replace(".", "").strip()
        
        if "REFUSALNONDENTAL" in clean_text and len(diagnosis_text) < 60:
            if user_lang == 'ar':
                refusal = "معلش، أنا بس بجاوب على الأسئلة اللي ليها علاقة بالأسنان وصحة الفم."
            else:
                refusal = "I can only answer questions about dental and oral health."
            history.append({"role": "assistant", "content": refusal})
            return make_json_response({"session_id": session_id, "reply": refusal})

        # Decode unicode escapes
        try:
            reply = ai_client.decode_unicode_escapes(diagnosis_text)
        except Exception:
            reply = diagnosis_text

        # Append assistant message to history
        history.append({"role": "assistant", "content": reply})

        return make_json_response({"session_id": session_id, "reply": reply})

    except Exception as e:
        tb = traceback.format_exc()
        print(f"\n{'='*60}")
        print(f"[CHAT ERROR] Internal error in /api/chat endpoint:")
        print(f"{'='*60}")
        print(tb)
        print(f"{'='*60}\n")
        
        # Return user-friendly error message
        if user_lang == 'ar':
            error_message = "معلش، حصلت مشكلة وأنا بجهز الرد. جرب تاني لو سمحت."
        else:
            error_message = "Sorry, an error occurred while processing your request. Please try again."
        
        return make_json_response({
            "session_id": session_id,
            "reply": error_message,
            "error": "service_unavailable"
        }, status=500)

@app.route("/api/session/<session_id>", methods=["GET"])
def get_session(session_id):
    """Get session details."""
    session = SESSIONS.get(session_id)
    if not session:
        return jsonify({"error": "session not found"}), 404
    return jsonify({"session": session})

# ==================== MAIN ====================

if __name__ == "__main__":
    print("[RULE_BOT] Starting hybrid rule-based + AI chatbot server on port 5005")
    print(f"[RULE_BOT] Questions loaded: {len(QUESTIONS)}")
    print(f"[RULE_BOT] AI initialized: {init_error is None}")
    app.run(host="0.0.0.0", port=5010, debug=True)
