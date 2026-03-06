"""
CORS Proxy Server for Teeth Management System
This script acts as an intermediate layer between the frontend and backend,
handling CORS and forwarding all requests to the Spring Boot backend.
"""

from flask import Flask, request, jsonify, Response
from flask_cors import CORS
import requests
import json
import os

app = Flask(__name__)

# Enable CORS for all routes
CORS(app, resources={
    r"/*": {
        "origins": "*",
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization", "Accept", "X-Requested-With"],
        "expose_headers": ["Content-Type", "Authorization"],
        "supports_credentials": True
    }
})

# Backend configuration - use environment variables for production
BACKEND_URL = os.getenv("BACKEND_URL", "http://localhost:8080")
PROXY_PORT = int(os.getenv("PROXY_PORT", "5173"))

# Proxy all requests to backend
@app.route('/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'])
def proxy(path):
    """
    Forward all requests to the backend server
    """
    # Handle preflight OPTIONS requests
    if request.method == 'OPTIONS':
        response = Response()
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, Accept, X-Requested-With'
        response.headers['Access-Control-Max-Age'] = '3600'
        return response

    # Build the target URL
    url = f"{BACKEND_URL}/{path}"
    
    # Get query parameters
    if request.query_string:
        url += f"?{request.query_string.decode('utf-8')}"

    # Prepare headers (exclude host-specific headers)
    headers = {}
    for key, value in request.headers:
        if key.lower() not in ['host', 'connection']:
            headers[key] = value

    try:
        # Forward the request based on method
        if request.method == 'GET':
            backend_response = requests.get(url, headers=headers, timeout=30)
        elif request.method == 'POST':
            backend_response = requests.post(
                url,
                data=request.get_data(),
                headers=headers,
                timeout=30
            )
        elif request.method == 'PUT':
            backend_response = requests.put(
                url,
                data=request.get_data(),
                headers=headers,
                timeout=30
            )
        elif request.method == 'DELETE':
            backend_response = requests.delete(url, headers=headers, timeout=30)
        else:
            return jsonify({"error": "Method not allowed"}), 405

        # Create response with backend data
        response = Response(
            backend_response.content,
            status=backend_response.status_code,
            content_type=backend_response.headers.get('Content-Type', 'application/json')
        )

        # Copy relevant headers from backend response
        excluded_headers = ['content-encoding', 'content-length', 'transfer-encoding', 'connection']
        for key, value in backend_response.headers.items():
            if key.lower() not in excluded_headers:
                response.headers[key] = value

        return response

    except requests.exceptions.ConnectionError:
        app.logger.error(f"Connection error: Could not connect to {BACKEND_URL}")
        return jsonify({
            "error": "Backend server is not available",
            "message": f"Could not connect to {BACKEND_URL}"
        }), 503
    except requests.exceptions.Timeout:
        app.logger.error(f"Timeout error: Backend server took too long to respond")
        return jsonify({
            "error": "Request timeout",
            "message": "Backend server took too long to respond"
        }), 504
    except Exception as e:
        app.logger.error(f"Proxy error: {str(e)}")
        return jsonify({
            "error": "Proxy error",
            "message": str(e)
        }), 500


# Root endpoint
@app.route('/', methods=['GET'])
def root():
    return jsonify({
        "service": "CORS Proxy Server",
        "version": "1.0",
        "backend": BACKEND_URL,
        "status": "running"
    })


# Health check endpoint
@app.route('/health', methods=['GET'])
def health():
    try:
        # Check if backend is reachable
        response = requests.get(f"{BACKEND_URL}/api/category/getCategories", timeout=5)
        backend_status = "healthy" if response.status_code < 500 else "unhealthy"
    except:
        backend_status = "unreachable"
    
    return jsonify({
        "proxy": "healthy",
        "backend": backend_status,
        "backend_url": BACKEND_URL
    })


if __name__ == '__main__':
    print(f"""
    ╔═══════════════════════════════════════════════════════════╗
    ║         CORS Proxy Server - Teeth Management System       ║
    ╠═══════════════════════════════════════════════════════════╣
    ║  Proxy Server: http://localhost:{PROXY_PORT}              ║
    ║  Backend URL:  {BACKEND_URL}                              ║
    ║  Status: Running...                                       ║
    ║                                                           ║
    ║  NOTE: For production, use gunicorn instead:              ║
    ║  gunicorn -w 4 -b 0.0.0.0:{PROXY_PORT} proxy_server:app  ║
    ╚═══════════════════════════════════════════════════════════╝
    """)
    
    # Run the Flask app (development only)
    app.run(
        host='0.0.0.0',
        port=PROXY_PORT,
        debug=True,
        threaded=True
    )
