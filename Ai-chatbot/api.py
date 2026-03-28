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
        "E": {"next": "Q2E"},
        "F": {"chatbot": True}
    },
    "Q2A": {
        "A1": {"next": "Q3A"},
        "A2": {"next": "Q4A"}
    },
    "Q3A": {
        "A1a": {"next": "Q3C"},
        "A1b": {"next": "Q3B"}
    },
    "Q3B": {
        "B1a": {"category": "Cosmetic Filling"},
        "B1b": {"category": "Fixed Prosthetics (Crowns and Bridges)"},
        "B1c": {"chatbot": True}
    },
    "Q3C": {
        "C1a": {"category": "Cosmetic Filling"}, # Front tooth hole
        "C1b": {"category": "Amalgam Filling"}   # Back tooth hole
    },
    "Q3D": {
        "D2a": {"category": "Cosmetic Filling"},                       # Front tooth chip
        "D2b": {"category": "Fixed Prosthetics (Crowns and Bridges)"}  # Back tooth chip/break
    },
    "Q4A": {
        "A2a": {"category": "Endodontic Fillings (Root Canal)"},
        "A2b": {"category": "Fixed Prosthetics (Crowns and Bridges)"} # Bypasses the deleted Q5A
    },
    "Q2B": {
        "B1": {"category": "Orthodontics"},
        "B2": {"category": "Pediatric Dentistry"}
    },
    "Q2C": {
        "C1": {"category": "Dental Implants"},
        "C2": {"category": "Fixed Prosthetics (Crowns and Bridges)"},
        "C3": {"category": "Removable Prosthetics"}
    },
    "Q2D": {
        "D1": {"category": "Fixed Prosthetics (Crowns and Bridges)"}, # Large break
        "D2": {"next": "Q3D"},                                        # Small hole/chip -> Ask if front/back
        "D3": {"chatbot": True}
    },
    "Q2E": {
        "E1": {"category": "Cleaning and Whitening"},
        "E2": {"category": "Surgery and Extraction"},
        "E3": {"chatbot": True}
    }
}

# Allowed final categories
CATEGORIES = [
    "Cosmetic Filling",
    "Amalgam Filling",
    "Endodontic Fillings (Root Canal)",
    "Fixed Prosthetics (Crowns and Bridges)",
    "Removable Prosthetics",
    "Dental Implants",
    "Cleaning and Whitening",
    "Orthodontics",
    "Surgery and Extraction",
    "Pediatric Dentistry"
]

# Category translations
CATEGORY_TRANSLATIONS = {
    "Cosmetic Filling": {"en": "Cosmetic Filling", "ar": "حشو تجميلي"},
    "Amalgam Filling": {"en": "Amalgam Filling", "ar": "حشو املجم"},
    "Endodontic Fillings (Root Canal)": {"en": "Endodontic Fillings (Root Canal)", "ar": "حشو عصب"},
    "Fixed Prosthetics (Crowns and Bridges)": {"en": "Fixed Prosthetics (Crowns and Bridges)", "ar": "تيجان وجسور"},
    "Removable Prosthetics": {"en": "Removable Prosthetics", "ar": "تركيبات متحركة"},
    "Dental Implants": {"en": "Dental Implants", "ar": "زراعة الأسنان"},
    "Cleaning and Whitening": {"en": "Cleaning and Whitening", "ar": "تنظيف وتبييض الأسنان"},
    "Orthodontics": {"en": "Orthodontics", "ar": "تقويم الأسنان"},
    "Surgery and Extraction": {"en": "Surgery and Extraction", "ar": "الجراحة والخلع"},
    "Pediatric Dentistry": {"en": "Pediatric Dentistry", "ar": "طب أسنان الأطفال"}
}

def validate_transitions():
    """Validate that TRANSITIONS reference existing questions/options and allowed categories."""
    errors = []
    if not QUESTIONS:
        errors.append("QUESTIONS is empty or failed to load questions.json")

    for qid, rules in TRANSITIONS.items():
        if qid not in QUESTIONS:
            errors.append(f"TRANSITIONS references unknown question id: {qid}")
            continue
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
            return (None, current_q, " -> ".join(path) + " -> default")
        if "category" in outcome:
            return (outcome["category"], " -> ".join(path))
        if "next" in outcome:
            next_q = outcome["next"]
            current_q = next_q
            continue

    return (None, current_q, " -> ".join(path))

def make_json_response(obj, status=200):
    return Response(json.dumps(obj, ensure_ascii=False), status=status, mimetype='application/json')

@app.after_request
def add_cors_headers(response):
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

@app.route("/resolve", methods=["POST"])
def resolve():
    payload = request.get_json(force=True)
    answers = payload.get("answers") or []
    if not isinstance(answers, list) or len(answers) == 0:
        return jsonify({"error": "answers (non-empty list) required"}), 400

    res = evaluate_answers(answers)
    if res[0]:
        return jsonify({"category": res[0], "reason": res[1]})
    else:
        next_q = res[1]
        path = res[2]
        qobj = localized_question(next_q, payload.get("language")) if next_q else None
        return jsonify({"category": None, "next_question": qobj, "reason": path})

@app.route("/session/start", methods=["POST"])
def start_session():
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
        "chatbot_mode": False
    }
    SESSIONS[session_id] = session
    return jsonify({
        "session_id": session_id,
        "question": localized_question("Q0", None),
        "session": session
    })

def trigger_chatbot(session, session_id, reason=" -> default chatbot"):
    session["chatbot_mode"] = True
    session["resolved"] = True
    session["reason"] = decision_path_reason(session) + reason
    lang = session.get("language", "en")
    
    if lang == "ar":
        chat_message = "تم تفعيل وضع الدردشة. يمكنك الآن التحدث معي عن أي مشكلة أسنان."
    else:
        chat_message = "Chat mode activated. You can now talk to me about any dental issue."
        
    session_histories[session_id] = []
    
    return jsonify({
        "chatbot_activated": True,
        "message": chat_message,
        "session": session
    })

@app.route("/session/answer", methods=["POST"])
def answer():
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

    q = QUESTIONS.get(question_id)
    if not q:
        return jsonify({"error": "invalid question_id"}), 400
    valid_ids = [opt["id"] for opt in q["options"]]
    if answer_id not in valid_ids:
        return jsonify({"error": "invalid answer_id for question", "valid_options": valid_ids}), 400

    record_answer(session, question_id, answer_id)

    if question_id == "Q0":
        aid = answer_id.upper()
        if aid == "AR":
            lang = "ar"
        elif aid == "EN":
            lang = "en"
        else:
            lang = "en"  # Default fallback

        session["language"] = lang
        session["current_question_id"] = "Q1"
        return jsonify({"question": localized_question("Q1", lang), "session": session})

    trans = TRANSITIONS.get(question_id, {})
    outcome = trans.get(answer_id)
    
    if not outcome:
        return trigger_chatbot(session, session_id, " -> default")

    if outcome.get("chatbot"):
        return trigger_chatbot(session, session_id, " -> triggered chatbot from rules")

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

    if "next" in outcome:
        next_q = outcome["next"]
        session["current_question_id"] = next_q
        
        if len(session["answers"]) >= 6 and not session["resolved"]:
            return trigger_chatbot(session, session_id, " -> fallback after max follow-ups")

        return jsonify({"question": localized_question(next_q, session.get("language")), "session": session})

    return trigger_chatbot(session, session_id, " -> unknown outcome")

@app.route('/chat', methods=['POST'])
def chat():
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

    if ai_client is None:
        return make_json_response({
            "error": "AI client module failed to import",
            "details": "Check server logs for import errors"
        }, status=500)

    session = SESSIONS.get(session_id)
    user_lang = session.get("language", "en") if session else "en"
    
    if ai_client.is_arabic(message):
        user_lang = 'ar'

    history = session_histories.setdefault(session_id, [])
    history.append({"role": "user", "content": message})

    try:
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

        clean_text = diagnosis_text.upper().replace("_", "").replace(" ", "").replace(".", "").strip()
        
        if "REFUSALNONDENTAL" in clean_text and len(diagnosis_text) < 60:
            if user_lang == 'ar':
                refusal = "معلش، أنا بس بجاوب على الأسئلة اللي ليها علاقة بالأسنان وصحة الفم."
            else:
                refusal = "I can only answer questions about dental and oral health."
            history.append({"role": "assistant", "content": refusal})
            return make_json_response({"session_id": session_id, "reply": refusal})

        try:
            reply = ai_client.decode_unicode_escapes(diagnosis_text)
        except Exception:
            reply = diagnosis_text

        history.append({"role": "assistant", "content": reply})

        return make_json_response({"session_id": session_id, "reply": reply})

    except Exception as e:
        tb = traceback.format_exc()
        print(f"\n{'='*60}")
        print(f"[CHAT ERROR] Internal error in /chat endpoint:")
        print(f"{'='*60}")
        print(tb)
        print(f"{'='*60}\n")
        
        if user_lang == 'ar':
            error_message = "معلش، حصلت مشكلة وأنا بجهز الرد. جرب تاني لو سمحت."
        else:
            error_message = "Sorry, an error occurred while processing your request. Please try again."
        
        return make_json_response({
            "session_id": session_id,
            "reply": error_message,
            "error": "service_unavailable"
        }, status=500)

@app.route("/session/<session_id>", methods=["GET"])
def get_session(session_id):
    session = SESSIONS.get(session_id)
    if not session:
        return jsonify({"error": "session not found"}), 404
    return jsonify({"session": session})

if __name__ == "__main__":
    print("[RULE_BOT] Starting hybrid rule-based + AI chatbot server on port 5010")
    print(f"[RULE_BOT] Questions loaded: {len(QUESTIONS)}")
    print(f"[RULE_BOT] AI initialized: {init_error is None}")
    app.run(host="0.0.0.0", port=5010, debug=True)
