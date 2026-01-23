Rule-based Dental Chatbot (API)

Overview
- Deterministic, decision-tree based chatbot exposed over a JSON API.
- Endpoints:
  - POST /api/session/start -> starts session, returns first question
  - POST /api/session/answer -> submit answer, returns next question or final result
  - GET /api/session/{session_id} -> fetch session state

Quick start (local)

1) Create and activate a Python environment (optional):

```bash
python3 -m venv venv
source venv/bin/activate
```

2) Install requirements:

```bash
pip install -r requirements.txt
```

3) Run the service:

```bash
python app.py
```

Example flow (curl)

Start session:

```bash
curl -s -X POST http://localhost:5005/api/session/start | jq
```

Answer Q1 with answer A:

```bash
curl -s -X POST http://localhost:5005/api/session/answer \
  -H 'Content-Type: application/json' \
  -d '{"session_id":"<id>","question_id":"Q1","answer_id":"A"}' | jq
```

Notes
- Sessions are stored in-memory for simplicity. Replace with Redis/DB for production.
- All logic is deterministic and uses exact option IDs (no NLP).
- The service returns an explicit `reason` when it resolves the final category.
