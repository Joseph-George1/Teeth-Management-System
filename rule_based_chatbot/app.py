from flask import Flask, request, jsonify
from flask_cors import CORS
from uuid import uuid4
from datetime import datetime
import os
import json

app = Flask(__name__)
CORS(app)

# Load questions from external JSON for scalability
QUESTIONS = {}
QUESTIONS_PATH = os.path.join(os.path.dirname(__file__), "questions.json")
if os.path.isfile(QUESTIONS_PATH):
    try:
        with open(QUESTIONS_PATH, "r", encoding="utf-8") as f:
            QUESTIONS = json.load(f)
    except Exception:
        QUESTIONS = {}
else:
    QUESTIONS = {}
    
# Deterministic transitions: either point to next question id or to a final category
TRANSITIONS = {
    "Q1": {
        "A": {"next": "Q2A"},
        "B": {"next": "Q2B"},
        "C": {"next": "Q2C"},
        "D": {"next": "Q2D"},
        "E": {"category": "Comprehensive Dental Examination"},
        "F": {"next": "Q2F"},
        "G": {"next": "Q2G"}
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


def get_localized_category(category, language):
    """Return category name in specified language (en or ar)."""
    if category not in CATEGORY_TRANSLATIONS:
        return category
    lang = language if language in ("en", "ar") else "en"
    return CATEGORY_TRANSLATIONS[category].get(lang, category)


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
validate_transitions()

# In-memory session store (simple); production should use DB or Redis
SESSIONS = {}


def now_iso():
    return datetime.utcnow().isoformat() + "Z"


def build_question(qid):
    q = QUESTIONS.get(qid)
    if not q:
        return None
    # Determine language-aware text (default to English)
    # language may be passed via session when calling build_question elsewhere
    # Here we return placeholders; caller should pass session language when available
    return {"id": q["id"], "text": q.get("text_en") or q.get("text"), "options": q.get("options", [])}


def record_answer(session, question_id, answer_id):
    session["answers"].append({
        "question_id": question_id,
        "answer_id": answer_id,
        "timestamp": now_iso()
    })


def localized_question(qid, language):
    """Return question and options localized to `language` ('en' or 'ar').
    If language is None, default to English for the language selection question.
    """
    q = QUESTIONS.get(qid)
    if not q:
        return None
    lang = language if language in ("en", "ar") else "en"
    # Special-case: language selection question should display both language labels when language is None
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
    session_id = str(uuid4())
    session = {
        "session_id": session_id,
        "created_at": now_iso(),
        "current_question_id": "Q0",
        "answers": [],
        "resolved": False,
        "category": None,
        "reason": None,
        "language": None
    }
    SESSIONS[session_id] = session
    # Return the language-selection question (Q0). build localized question below when language selected.
    return jsonify({"session_id": session_id, "question": localized_question("Q0", None), "session": session})


@app.route("/api/session/answer", methods=["POST"])
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
        return jsonify({"error": "question_id does not match current session question", "current_question_id": session["current_question_id"]}), 400

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
        # Map answer ids to language codes (expect EN or AR)
        aid = answer_id.upper()
        if aid == "AR":
            lang = "ar"
        else:
            lang = "en"
        session["language"] = lang
        # proceed to first content question
        session["current_question_id"] = "Q1"
        return jsonify({"question": localized_question("Q1", lang), "session": session})

    # Determine transition
    trans = TRANSITIONS.get(question_id, {})
    outcome = trans.get(answer_id)
    if not outcome:
        # If no transition found, default to Comprehensive Dental Examination
        session["resolved"] = True
        session["category"] = "Comprehensive Dental Examination"
        session["reason"] = decision_path_reason(session) + " -> default"
        localized_cat = get_localized_category(session["category"], session.get("language"))
        return jsonify({"result": {"category": localized_cat, "category_en": session["category"], "reason": session["reason"]}, "session": session})

    if "category" in outcome:
        session["resolved"] = True
        session["category"] = outcome["category"]
        session["reason"] = decision_path_reason(session)
        session["current_question_id"] = None
        localized_cat = get_localized_category(session["category"], session.get("language"))
        return jsonify({"result": {"category": localized_cat, "category_en": session["category"], "reason": session["reason"]}, "session": session})

    if "next" in outcome:
        next_q = outcome["next"]
        session["current_question_id"] = next_q
        # Safety: if follow-ups exceed 2 and still ambiguous, default
        if len(session["answers"]) >= 3 and not session["resolved"]:
            session["resolved"] = True
            session["category"] = "Comprehensive Dental Examination"
            session["reason"] = decision_path_reason(session) + " -> fallback after max follow-ups"
            localized_cat = get_localized_category(session["category"], session.get("language"))
            return jsonify({"result": {"category": localized_cat, "category_en": session["category"], "reason": session["reason"]}, "session": session})

        # Return next question localized to chosen language
        return jsonify({"question": localized_question(next_q, session.get("language")), "session": session})

    # Unknown outcome structure
    session["resolved"] = True
    session["category"] = "Comprehensive Dental Examination"
    session["reason"] = decision_path_reason(session) + " -> unknown outcome"
    localized_cat = get_localized_category(session["category"], session.get("language"))
    return jsonify({"result": {"category": localized_cat, "category_en": session["category"], "reason": session["reason"]}, "session": session})


@app.route("/api/session/<session_id>", methods=["GET"])
def get_session(session_id):
    session = SESSIONS.get(session_id)
    if not session:
        return jsonify({"error": "session not found"}), 404
    return jsonify({"session": session})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5005)
