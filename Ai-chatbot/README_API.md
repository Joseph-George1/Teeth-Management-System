Flask API for Thoutha (AI dental assistant)
=========================================

This file describes how to run the Flask-based HTTP API that wraps the existing `Thoutha` AI client so other websites can call it.

Files added
- `Ai-chatbot/flask_api.py` — Flask app exposing `/chat` and `/health` endpoints.

Quick start (PowerShell)

1. Create and activate a venv (optional but recommended):

    python -m venv .venv
    .\.venv\Scripts\Activate.ps1

2. Install dependencies (Streamlit app already has a requirements file; add Flask):

    pip install -r Ai-chatbot\requirements.txt
    pip install flask

3. Set your Gemini API key for the session (or create a `.env` with GEMINI_API_KEY):

    Option A (temporary for current PowerShell session):

        $env:GEMINI_API_KEY = 'your_api_key_here'

    Option B (recommended for convenience): create a `.env` file. You can place
    the `.env` either in the `Ai-chatbot` folder or in the project root (one level
    above). Example `.env` contents:

        GEMINI_API_KEY=your_api_key_here

4. Run the API:

    python Ai-chatbot\flask_api.py

The server listens on port 5000 by default.

API endpoints

- GET /health
    - Returns basic health and whether the AI client initialized.

- POST /chat
    - Request JSON: { "message": "user text", "session_id": "optional" }
    - Response JSON: { "session_id": "...", "reply": "assistant text", "doctor": {...} (optional) }

Notes

- The Flask API uses an in-memory session store (a Python dict). For production use you should use a persistent store like Redis.
- CORS is enabled minimally (Access-Control-Allow-Origin: *). Tighten this for production.
- The API uses the same `doctors.db` file as the Streamlit app. Ensure it's accessible to the Flask process.
