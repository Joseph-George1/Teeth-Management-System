"""
Flask application for password reset functionality with OTP verification.
This service integrates with OTP_W.py for WhatsApp OTP and Oracle database for user management.
"""

import os
import logging
import secrets
from datetime import datetime, timedelta
from functools import wraps

import oracledb
import bcrypt
import requests
from flask import Flask, request, jsonify
from flask_cors import CORS

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ─────────────────────────────────────────────
#  CONFIGURATION
# ─────────────────────────────────────────────
# Port Configuration for Teeth Management System:
# - 8080: Spring Boot Backend
# - 5010: AI Chatbot Service
# - 8000: OTP WhatsApp Service (OTP_W.py)
# - 6500: Admin Dashboard
# - 5173: Proxy Server
# - 7000: Password Reset Service (this service)

OTP_SERVICE_URL = os.getenv("OTP_SERVICE_URL", "http://127.0.0.1:8000")
DB_USER = os.getenv("DB_USER", "hr")
DB_PASSWORD = os.getenv("DB_PASSWORD", "hr")
DB_DSN = os.getenv("DB_DSN", "localhost:1521/orclpdb")
FLASK_PORT = int(os.getenv("FORGET_PASSWORD_PORT", "7000"))
SECRET_KEY = os.getenv("SECRET_KEY", secrets.token_hex(32))

# OTP verification tracking (phone_number -> {verified: bool, timestamp: datetime})
otp_verified_sessions = {}
SESSION_EXPIRY_MINUTES = 10  # Time window to change password after OTP verification

# ─────────────────────────────────────────────
#  FLASK APP SETUP
# ─────────────────────────────────────────────
app = Flask(__name__)
app.secret_key = SECRET_KEY
CORS(app)

# ─────────────────────────────────────────────
#  DATABASE CONNECTION
# ─────────────────────────────────────────────
def get_db_connection():
    """Create and return a database connection."""
    try:
        connection = oracledb.connect(
            user=DB_USER,
            password=DB_PASSWORD,
            dsn=DB_DSN
        )
        logger.info("Database connection established successfully")
        return connection
    except Exception as e:
        logger.error(f"Database connection failed: {str(e)}")
        raise

# ─────────────────────────────────────────────
#  HELPER FUNCTIONS
# ─────────────────────────────────────────────
def find_user_by_phone(phone_number):
    """
    Find user (Doctor or Patient) by phone number.
    Note: Admin accounts don't have phone numbers in the schema.
    Returns: tuple (user_type, user_data) or (None, None) if not found
    """
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Try finding in Doctor table
        cursor.execute(
            """SELECT ID, FIRST_NAME, LAST_NAME, EMAIL, PASSWORD, PHONE_NUMBER 
               FROM DOCTOR 
               WHERE PHONE_NUMBER = :phone""",
            {"phone": phone_number}
        )
        result = cursor.fetchone()
        
        if result:
            user_data = {
                'id': result[0],
                'first_name': result[1],
                'last_name': result[2],
                'email': result[3],
                'password': result[4],
                'phone_number': result[5]
            }
            cursor.close()
            return 'doctor', user_data
        
        # Try finding in Patients table (no email or password fields)
        # Patients can only be found but cannot reset password (no password field in schema)
        cursor.execute(
            """SELECT ID, FIRST_NAME, LAST_NAME, PHONE_NUMBER 
               FROM PATIENTS 
               WHERE PHONE_NUMBER = :phone""",
            {"phone": phone_number}
        )
        result = cursor.fetchone()
        
        if result:
            # Patients don't have email or password in the current schema
            # This is for future compatibility if schema changes
            user_data = {
                'id': result[0],
                'first_name': result[1],
                'last_name': result[2],
                'phone_number': result[3],
                'email': None,
                'password': None
            }
            cursor.close()
            # Return None since patients don't have passwords to reset
            logger.info(f"Found patient but they don't have password field")
            return None, None
        
        cursor.close()
        return None, None
        
    except Exception as e:
        logger.error(f"Error finding user by phone: {str(e)}")
        raise
    finally:
        if conn:
            conn.close()


def update_user_password(user_type, user_id, new_password_hash):
    """
    Update user password in the database.
    Args:
        user_type: 'doctor' (only doctors have passwords)
        user_id: User ID
        new_password_hash: BCrypt hashed password
    """
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Only doctors can reset passwords (patients and admins use different auth)
        if user_type != 'doctor':
            raise ValueError(f"Password reset not supported for user type: {user_type}")
        
        cursor.execute(
            "UPDATE DOCTOR SET PASSWORD = :pwd WHERE ID = :uid",
            {"pwd": new_password_hash, "uid": user_id}
        )
        
        conn.commit()
        cursor.close()
        logger.info(f"Password updated successfully for {user_type} ID: {user_id}")
        
    except Exception as e:
        if conn:
            conn.rollback()
        logger.error(f"Error updating password: {str(e)}")
        raise
    finally:
        if conn:
            conn.close()


def hash_password(password):
    """
    Hash password using BCrypt (compatible with Spring Security).
    Spring Security uses BCrypt with $2a$ prefix and 10 rounds by default.
    """
    # Use 10 rounds (Spring Security default)
    salt = bcrypt.gensalt(rounds=10)
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    # Convert bytes to string, BCrypt format: $2b$...
    hashed_str = hashed.decode('utf-8')
    # Spring Security uses $2a$ prefix, Python bcrypt uses $2b$
    # They are compatible, but for exact compatibility, we keep $2b$
    # Spring Security BCryptPasswordEncoder accepts both $2a$ and $2b$
    return hashed_str


def cleanup_expired_sessions():
    """Remove expired OTP verification sessions."""
    now = datetime.now()
    expired = [
        phone for phone, data in otp_verified_sessions.items()
        if (now - data['timestamp']).total_seconds() > SESSION_EXPIRY_MINUTES * 60
    ]
    for phone in expired:
        del otp_verified_sessions[phone]
    if expired:
        logger.info(f"Cleaned up {len(expired)} expired sessions")


# ─────────────────────────────────────────────
#  API ENDPOINTS
# ─────────────────────────────────────────────

@app.route('/api/password-reset/request', methods=['POST'])
def request_password_reset():
    """
    Step 1: Request password reset by sending OTP to phone number.
    Body: { "phone_number": "+1234567890" }
    """
    try:
        data = request.get_json()
        phone_number = data.get('phone_number', '').strip()
        
        if not phone_number:
            return jsonify({
                'success': False,
                'message': 'Phone number is required'
            }), 400
        
        # Validate phone number format
        if not phone_number.startswith('+'):
            return jsonify({
                'success': False,
                'message': 'Phone number must start with + (international format)'
            }), 400
        
        # Check if user exists
        user_type, user_data = find_user_by_phone(phone_number)
        
        if not user_type:
            return jsonify({
                'success': False,
                'message': 'No account found with this phone number'
            }), 404
        
        # Send OTP via OTP service
        try:
            otp_response = requests.post(
                f"{OTP_SERVICE_URL}/api/otp/send",
                json={"phone_number": phone_number},
                timeout=10
            )
            
            if otp_response.status_code == 200:
                otp_data = otp_response.json()
                logger.info(f"OTP sent successfully to {phone_number}")
                return jsonify({
                    'success': True,
                    'message': 'OTP sent successfully to your WhatsApp',
                    'expires_in_seconds': otp_data.get('expires_in_seconds'),
                    'user_email': user_data['email']  # Return masked email for confirmation
                }), 200
            elif otp_response.status_code == 429:
                error_detail = otp_response.json().get('detail', 'Too many requests')
                return jsonify({
                    'success': False,
                    'message': error_detail
                }), 429
            else:
                logger.error(f"OTP service error: {otp_response.status_code}")
                return jsonify({
                    'success': False,
                    'message': 'Failed to send OTP. Please try again.'
                }), 500
                
        except requests.exceptions.ConnectionError:
            logger.error("Cannot connect to OTP service")
            return jsonify({
                'success': False,
                'message': 'OTP service is currently unavailable'
            }), 503
        except Exception as e:
            logger.error(f"Error calling OTP service: {str(e)}")
            return jsonify({
                'success': False,
                'message': 'An error occurred while sending OTP'
            }), 500
            
    except Exception as e:
        logger.error(f"Error in request_password_reset: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'An internal error occurred'
        }), 500


@app.route('/api/password-reset/verify-otp', methods=['POST'])
def verify_otp():
    """
    Step 2: Verify OTP code.
    Body: { "phone_number": "+1234567890", "otp": "123456" }
    """
    try:
        cleanup_expired_sessions()
        
        data = request.get_json()
        phone_number = data.get('phone_number', '').strip()
        otp_code = data.get('otp', '').strip()
        
        if not phone_number or not otp_code:
            return jsonify({
                'success': False,
                'message': 'Phone number and OTP are required'
            }), 400
        
        # Check if user exists
        user_type, user_data = find_user_by_phone(phone_number)
        
        if not user_type:
            return jsonify({
                'success': False,
                'message': 'No account found with this phone number'
            }), 404
        
        # Verify OTP with OTP service
        try:
            otp_response = requests.post(
                f"{OTP_SERVICE_URL}/api/otp/verify",
                json={
                    "phone_number": phone_number,
                    "otp": otp_code
                },
                timeout=10
            )
            
            if otp_response.status_code == 200:
                # OTP verified successfully
                otp_verified_sessions[phone_number] = {
                    'verified': True,
                    'timestamp': datetime.now(),
                    'user_type': user_type,
                    'user_id': user_data['id']
                }
                logger.info(f"OTP verified successfully for {phone_number}")
                return jsonify({
                    'success': True,
                    'message': 'OTP verified successfully. You can now reset your password.',
                    'session_expires_in_minutes': SESSION_EXPIRY_MINUTES
                }), 200
            elif otp_response.status_code == 400:
                error_detail = otp_response.json().get('detail', 'Invalid OTP')
                return jsonify({
                    'success': False,
                    'message': error_detail
                }), 400
            elif otp_response.status_code == 404:
                return jsonify({
                    'success': False,
                    'message': 'No OTP found. Please request a new one.'
                }), 404
            elif otp_response.status_code == 410:
                return jsonify({
                    'success': False,
                    'message': 'OTP has expired. Please request a new one.'
                }), 410
            elif otp_response.status_code == 429:
                return jsonify({
                    'success': False,
                    'message': 'Maximum verification attempts exceeded. Please request a new OTP.'
                }), 429
            else:
                logger.error(f"OTP verification error: {otp_response.status_code}")
                return jsonify({
                    'success': False,
                    'message': 'OTP verification failed. Please try again.'
                }), 500
                
        except requests.exceptions.ConnectionError:
            logger.error("Cannot connect to OTP service")
            return jsonify({
                'success': False,
                'message': 'OTP service is currently unavailable'
            }), 503
        except Exception as e:
            logger.error(f"Error calling OTP service: {str(e)}")
            return jsonify({
                'success': False,
                'message': 'An error occurred during OTP verification'
            }), 500
            
    except Exception as e:
        logger.error(f"Error in verify_otp: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'An internal error occurred'
        }), 500


@app.route('/api/password-reset/change-password', methods=['POST'])
def change_password():
    """
    Step 3: Change password after OTP verification.
    Body: { 
        "phone_number": "+1234567890", 
        "new_password": "newpassword123",
        "confirm_password": "newpassword123"
    }
    """
    try:
        cleanup_expired_sessions()
        
        data = request.get_json()
        phone_number = data.get('phone_number', '').strip()
        new_password = data.get('new_password', '').strip()
        confirm_password = data.get('confirm_password', '').strip()
        
        # Validation
        if not phone_number or not new_password or not confirm_password:
            return jsonify({
                'success': False,
                'message': 'All fields are required'
            }), 400
        
        if new_password != confirm_password:
            return jsonify({
                'success': False,
                'message': 'Passwords do not match'
            }), 400
        
        if len(new_password) < 8:
            return jsonify({
                'success': False,
                'message': 'Password must be at least 8 characters long'
            }), 400
        
        # Check if OTP was verified for this phone number
        session = otp_verified_sessions.get(phone_number)
        
        if not session or not session.get('verified'):
            return jsonify({
                'success': False,
                'message': 'OTP not verified. Please verify OTP first.'
            }), 403
        
        # Check if session is still valid
        time_elapsed = (datetime.now() - session['timestamp']).total_seconds()
        if time_elapsed > SESSION_EXPIRY_MINUTES * 60:
            del otp_verified_sessions[phone_number]
            return jsonify({
                'success': False,
                'message': 'Verification session expired. Please start over.'
            }), 410
        
        # Verify user type is doctor (only doctors can reset passwords)
        if session['user_type'] != 'doctor':
            del otp_verified_sessions[phone_number]
            return jsonify({
                'success': False,
                'message': f"Password reset not supported for {session['user_type']} accounts."
            }), 400
        
        # Hash the new password
        password_hash = hash_password(new_password)
        
        # Update password in database
        update_user_password(
            session['user_type'],
            session['user_id'],
            password_hash
        )
        
        # Clear the session
        del otp_verified_sessions[phone_number]
        
        logger.info(f"Password changed successfully for user: {phone_number}")
        
        return jsonify({
            'success': True,
            'message': 'Password changed successfully. You can now login with your new password.'
        }), 200
        
    except Exception as e:
        logger.error(f"Error in change_password: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'An error occurred while changing password'
        }), 500


@app.route('/api/password-reset/health', methods=['GET'])
def health_check():
    """Health check endpoint."""
    try:
        # Test database connection
        conn = get_db_connection()
        conn.close()
        db_status = "connected"
    except Exception as e:
        logger.error(f"Health check - DB error: {str(e)}")
        db_status = "disconnected"
    
    try:
        # Test OTP service connection
        otp_response = requests.get(f"{OTP_SERVICE_URL}/health", timeout=5)
        otp_status = "connected" if otp_response.status_code == 200 else "error"
    except Exception as e:
        logger.error(f"Health check - OTP service error: {str(e)}")
        otp_status = "disconnected"
    
    return jsonify({
        'service': 'password-reset',
        'status': 'running',
        'timestamp': datetime.now().isoformat(),
        'dependencies': {
            'database': db_status,
            'otp_service': otp_status
        }
    }), 200


@app.route('/', methods=['GET'])
def root():
    """Root endpoint with API information."""
    return jsonify({
        'service': 'Password Reset API',
        'version': '1.0.0',
        'endpoints': {
            'request_reset': 'POST /api/password-reset/request',
            'verify_otp': 'POST /api/password-reset/verify-otp',
            'change_password': 'POST /api/password-reset/change-password',
            'health': 'GET /api/password-reset/health'
        },
        'description': 'Password reset service with OTP verification via WhatsApp'
    }), 200


# ─────────────────────────────────────────────
#  ERROR HANDLERS
# ─────────────────────────────────────────────
@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'success': False,
        'message': 'Endpoint not found'
    }), 404


@app.errorhandler(500)
def internal_error(error):
    logger.error(f"Internal server error: {str(error)}")
    return jsonify({
        'success': False,
        'message': 'An internal server error occurred'
    }), 500


# ─────────────────────────────────────────────
#  MAIN
# ─────────────────────────────────────────────
if __name__ == '__main__':
    logger.info(f"Starting Password Reset Service on port {FLASK_PORT}")
    logger.info(f"OTP Service URL: {OTP_SERVICE_URL}")
    logger.info(f"Database DSN: {DB_DSN}")
    
    app.run(
        host='0.0.0.0',
        port=FLASK_PORT,
        debug=False
    )
