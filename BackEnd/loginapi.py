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
    entry = users.get(email)
    # Support two storage formats:
    # - legacy: email -> base64(password) (string)
    # - new: email -> { "password": base64(password), ... } (dict)
    if isinstance(entry, dict):
        return entry.get('password')
    return entry


def create_demo_user(path=USERS_FILE):
    users = load_users(path)
    if not users:
        demo_email = 'test@example.com'
        demo_password = 'password123'
        encoded = base64.b64encode(demo_password.encode('utf-8')).decode('ascii')
        # Store demo user as a structured record (new format)
        users[demo_email] = {
            'password': encoded,
            'first_name': 'Test',
            'last_name': 'User',
            'phone': '0000000000',
            'faculty': 'dentistry',
            'year': '1',
            'governorate': 'cairo'
        }
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
        # Load the full user entry to return profile fields when available
        users = load_users()
        entry = users.get(email)
        first_name = None
        last_name = None
        faculty = None
        year = None
        governorate = None
        if isinstance(entry, dict):
            first_name = entry.get('first_name')
            last_name = entry.get('last_name')
            faculty = entry.get('faculty')
            year = entry.get('year')
            governorate = entry.get('governorate')

        resp = {'status': 'success', 'message': 'Login successful'}
        # Include names when present (keeps response compact otherwise)
        if first_name or last_name:
            resp['first_name'] = first_name
            resp['last_name'] = last_name
            resp['faculty'] = faculty
            resp['year'] = year
            resp['governorate'] = governorate

        return jsonify(resp), 200
    else:
        return jsonify({'status': 'error', 'message': 'Email/password incorrect'}), 401


@app.route('/register', methods=['POST'])
def register():
    """Register a new user.

    Accepts JSON with the following fields:
      - first_name, last_name, email, phone
      - faculty, year, governorate
      - password, confirm_password

    Stores each user as a structured object in `users.json`:
      { email: { 'password': base64(...), 'first_name': ..., ... } }

    Returns 201 on success, 400 on bad request, 409 if user exists.
    """
    if not request.is_json:
        return jsonify({'status': 'error', 'message': 'Bad request; content-type must be application/json'}), 400

    data = request.get_json()
    # Accept common key names
    first_name = data.get('first_name') or data.get('firstname') or data.get('firstName')
    last_name = data.get('last_name') or data.get('lastname') or data.get('lastName')
    email = data.get('email')
    phone = data.get('phone') or data.get('tel') or data.get('telephone')
    faculty = data.get('faculty')
    year = data.get('year')
    governorate = data.get('governorate') or data.get('governorate_id')
    password = data.get('password')
    confirm = data.get('confirm_password') or data.get('confirmPassword') or data.get('password_confirm')

    # Basic presence checks
    required = [first_name, last_name, email, phone, faculty, year, governorate, password, confirm]
    if not all(required):
        return jsonify({'status': 'error', 'message': 'Bad request; all registration fields required'}), 400

    if password != confirm:
        return jsonify({'status': 'error', 'message': 'Password and confirmation do not match'}), 402

    users = load_users()
    if email in users:
        return jsonify({'status': 'error', 'message': 'User already exists'}), 409

    encoded = base64.b64encode(password.encode('utf-8')).decode('ascii')
    users[email] = {
        'password': encoded,
        'first_name': first_name,
        'last_name': last_name,
        'phone': phone,
        'faculty': faculty,
        'year': str(year),
        'governorate': governorate
    }
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
