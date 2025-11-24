#!/usr/bin/env python3
"""
Flask login API using a simple JSON file store with base64-encoded passwords.

This implementation avoids any database. User accounts are stored in
`BackEnd/users.json` as a mapping { email: base64(password) }.

Security note: storing passwords in base64 is NOT secure. This follows your
request for a DB-less, base64 approach for development/testing only. For any
real deployment, use salted hashing (bcrypt/argon2) and HTTPS.
"""

from flask import Flask, request, jsonify
try:
    from flask_cors import CORS
except Exception:
    # Provide a clear error message when the optional package is missing.
    import sys
    print("Missing Python package 'flask-cors'. Install it with:")
    print("  python3 -m pip install flask-cors")
    print("If you use a virtualenv, activate it first then run the command.")
    sys.exit(1)
import os
import json
import base64


USERS_FILE = os.path.join(os.path.dirname(__file__), 'users.json')


def load_users(path=USERS_FILE):
    if not os.path.exists(path):
        return {}
    try:
        with open(path, 'r', encoding='utf-8') as fh:
            return json.load(fh)
    except Exception:
        return {}


def save_users(users: dict, path=USERS_FILE):
    with open(path, 'w', encoding='utf-8') as fh:
        json.dump(users, fh, indent=2)


def get_encoded_password(email: str):
    users = load_users()
    return users.get(email)


def create_demo_user(path=USERS_FILE):
    users = load_users(path)
    if not users:
        demo_email = 'test@example.com'
        demo_password = 'password123'
        encoded = base64.b64encode(demo_password.encode('utf-8')).decode('ascii')
        users[demo_email] = encoded
        save_users(users, path)
        print(f'Created demo user: {demo_email} / {demo_password}')


app = Flask(__name__)

# Allow cross-origin requests from browser/React clients. For development
# we allow all origins; restrict this in production to your frontend origin.
CORS(app, resources={r"/*": {"origins": "*"}})


@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok'})


@app.route('/login', methods=['POST'])
def login():
    if not request.is_json:
        return jsonify({'status': 'error', 'message': 'Bad request; content-type must be application/json'}), 400

    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({'status': 'error', 'message': 'Bad request; email and password required'}), 400

    encoded = get_encoded_password(email)
    if not encoded:
        return jsonify({'status': 'error', 'message': 'Email/password not found'}), 401

    try:
        stored = base64.b64decode(encoded.encode('ascii')).decode('utf-8')
    except Exception:
        return jsonify({'status': 'error', 'message': 'Stored password invalid'}), 500

    if password == stored:
        return jsonify({'status': 'success', 'message': 'Login successful'}), 200
    else:
        return jsonify({'status': 'error', 'message': 'Email/password incorrect'}), 401


@app.route('/register', methods=['POST'])
def register():
    """Register a new user (stores base64-encoded password in users.json).

    Returns 201 on success, 400 on bad request, 409 if user exists.
    """
    if not request.is_json:
        return jsonify({'status': 'error', 'message': 'Bad request; content-type must be application/json'}), 400

    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({'status': 'error', 'message': 'Bad request; email and password required'}), 400

    users = load_users()
    if email in users:
        return jsonify({'status': 'error', 'message': 'User already exists'}), 409

    encoded = base64.b64encode(password.encode('utf-8')).decode('ascii')
    users[email] = encoded
    save_users(users)
    return jsonify({'status': 'success', 'message': 'User registered'}), 201


@app.route('/sendotp', methods=['GET'])
def sendotp():
    """Return a fixed OTP for testing."""
    return jsonify({'status': 'success', 'otp': '123123'}), 200


def prepare_store():
    # create demo user if store empty
    create_demo_user(USERS_FILE)


if __name__ == '__main__':
    prepare_store()
    app.run(host='0.0.0.0', port=5000, debug=True)
