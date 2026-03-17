import os
import json
import secrets
from datetime import datetime, timezone, timedelta
from collections import Counter
from functools import wraps

import requests as http
from flask import (
    Flask, render_template_string, request, redirect,
    url_for, session, jsonify, flash,
)
from flask_cors import CORS

# ─────────────────────────────────────────────
#  CONFIGURATION
# ─────────────────────────────────────────────
BACKEND_URL    = os.getenv("BACKEND_URL",    "http://localhost:8080")
AI_URL         = os.getenv("AI_URL",         "http://127.0.0.1:5010")
OTP_URL        = os.getenv("OTP_URL",        "http://127.0.0.1:8000")
PROXY_URL      = os.getenv("PROXY_URL",      "http://127.0.0.1:5173")
DASHBOARD_PORT = int(os.getenv("DASHBOARD_PORT", "6500"))
REQUEST_TIMEOUT = 6  # seconds

# SECRET_KEY: MUST be consistent across restarts for sessions to persist
# Set SECRET_KEY env var to a fixed value in production!
if not os.getenv("SECRET_KEY"):
    # Use a file-based key that persists across restarts
    key_file = os.path.join(os.path.dirname(__file__), ".flask_secret")
    if os.path.exists(key_file):
        with open(key_file, 'r') as f:
            SECRET_KEY = f.read().strip()
    else:
        SECRET_KEY = secrets.token_hex(32)
        with open(key_file, 'w') as f:
            f.write(SECRET_KEY)
        print(f"Generated new SECRET_KEY and saved to {key_file}")
else:
    SECRET_KEY = os.getenv("SECRET_KEY")

# ─────────────────────────────────────────────
#  OBFUSCATED ROUTE PREFIX
#  All dashboard URLs are served under this prefix.
#  Anything outside it returns 404, making the admin
#  panel invisible to crawlers and path scanners.
#  Override via env:  ADMIN_PREFIX=/your-custom-path
# ─────────────────────────────────────────────
ADMIN_PREFIX = os.getenv("ADMIN_PREFIX", "/api/tms-mng-x7k2p9q3").rstrip("/")

app = Flask(__name__)
app.secret_key = SECRET_KEY
# Configure session to persist for 30 days
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(days=30)
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
app.config['SESSION_COOKIE_SECURE'] = True  # Set to True if using HTTPS
app.config['SESSION_COOKIE_NAME'] = 'tms_admin_sess'
# Use root path for cookie to ensure it works correctly
app.config['SESSION_COOKIE_PATH'] = '/'
# Don't refresh on every request to avoid session conflicts
app.config['SESSION_REFRESH_EACH_REQUEST'] = False
# Simple CORS - allow all for API endpoints
CORS(app)


# ─────────────────────────────────────────────
#  HELPERS — backend API calls
# ─────────────────────────────────────────────

def _auth_header():
    """Return the Authorization header dict using the token stored in session."""
    token = session.get("jwt_token", "")
    return {"Authorization": f"Bearer {token}"}


def _get(path, *, auth=True):
    """GET from the Spring Boot backend. Returns (data, status_code)."""
    headers = _auth_header() if auth else {}
    try:
        r = http.get(f"{BACKEND_URL}{path}", headers=headers, timeout=REQUEST_TIMEOUT)
        if r.status_code == 200:
            return r.json(), 200
        return None, r.status_code
    except Exception as exc:
        app.logger.warning(f"GET {path} failed: {exc}")
        return None, 503


def _put(path, *, data=None):
    """PUT to the Spring Boot backend. Returns (data, status_code)."""
    try:
        r = http.put(
            f"{BACKEND_URL}{path}",
            json=data,
            headers=_auth_header(),
            timeout=REQUEST_TIMEOUT,
        )
        if r.status_code == 200:
            return r.json() if r.text else {}, 200
        return None, r.status_code
    except Exception as exc:
        app.logger.warning(f"PUT {path} failed: {exc}")
        return None, 503


def _delete(path, *, params=None):
    """DELETE from the Spring Boot backend. Returns status_code."""
    try:
        r = http.delete(
            f"{BACKEND_URL}{path}",
            headers=_auth_header(),
            params=params,
            timeout=REQUEST_TIMEOUT,
        )
        return r.status_code
    except Exception as exc:
        app.logger.warning(f"DELETE {path} failed: {exc}")
        return 503


# ─────────────────────────────────────────────
#  HELPERS — service health checks (mirrors bot.py)
# ─────────────────────────────────────────────

def _check_backend():
    try:
        r = http.get(f"{BACKEND_URL}/api/category/getCategories",
                     timeout=REQUEST_TIMEOUT)
        if r.status_code < 500:
            return {"status": "healthy", "code": r.status_code}
        return {"status": "unhealthy", "code": r.status_code}
    except Exception as e:
        return {"status": "unreachable", "error": str(e)}


def _check_ai():
    try:
        r = http.get(f"{AI_URL}/health", timeout=REQUEST_TIMEOUT)
        data = r.json()
        data.setdefault("status", "ok" if r.status_code == 200 else "error")
        return data
    except Exception as e:
        return {"status": "error", "ai_initialized": False,
                "questions_loaded": False, "error": str(e)}


def _check_otp():
    try:
        r = http.get(f"{OTP_URL}/health", timeout=REQUEST_TIMEOUT)
        data = r.json()
        data.setdefault("status", "healthy" if r.status_code == 200 else "error")
        return data
    except Exception as e:
        return {"status": "error", "error": str(e)}


def _check_proxy():
    try:
        r = http.get(f"{PROXY_URL}/health", timeout=REQUEST_TIMEOUT)
        data = r.json()
        data.setdefault("proxy", "healthy" if r.status_code == 200 else "error")
        return data
    except Exception as e:
        return {"proxy": "error", "backend": "unknown", "error": str(e)}


def get_all_health():
    return {
        "backend": _check_backend(),
        "ai_chatbot": _check_ai(),
        "otp_system": _check_otp(),
        "cors_proxy": _check_proxy(),
        "checked_at": datetime.now(timezone.utc).isoformat(),
    }


# ─────────────────────────────────────────────
#  HELPERS — analytics aggregation
# ─────────────────────────────────────────────

def get_analytics(token):
    """Collect & aggregate data from the Spring Boot backend."""
    session["jwt_token"] = token  # ensure token is available in helpers

    doctors_raw, _ = _get("/api/doctor/getDoctors")
    requests_raw, _ = _get("/api/request/getAllRequests")
    categories_raw, _ = _get("/api/category/getCategories")
    cities_raw, _ = _get("/api/cities/getAllCities")

    doctors    = doctors_raw    or []
    reqs       = requests_raw   or []
    categories = categories_raw or []
    cities     = cities_raw     or []

    # ---- doctors aggregation ----
    doctors_by_category = Counter(d.get("categoryName", "Unknown") for d in doctors)
    doctors_by_city      = Counter(d.get("cityName", "Unknown")     for d in doctors)
    doctors_by_university = Counter(d.get("universityName", "Unknown") for d in doctors)

    # ---- requests aggregation ----
    requests_by_status   = Counter(r.get("status", "UNKNOWN") for r in reqs)
    requests_by_category = Counter(r.get("categoryName", "Unknown") for r in reqs)

    # ---- request timeline (by month from dateTime) ----
    timeline: Counter = Counter()
    for r in reqs:
        dt_str = r.get("dateTime")
        if dt_str:
            try:
                dt = datetime.fromisoformat(dt_str[:19])
                timeline[dt.strftime("%Y-%m")] += 1
            except Exception:
                pass
    sorted_timeline = dict(sorted(timeline.items()))

    return {
        "totals": {
            "doctors":    len(doctors),
            "requests":   len(reqs),
            "categories": len(categories),
            "cities":     len(cities),
            "appointments": 0,  # placeholder — Appointments API not yet exposed
        },
        "doctors_by_category":  dict(doctors_by_category.most_common()),
        "doctors_by_city":      dict(doctors_by_city.most_common()),
        "doctors_by_university": dict(doctors_by_university.most_common(10)),
        "requests_by_status":   dict(requests_by_status),
        "requests_by_category": dict(requests_by_category.most_common(10)),
        "requests_timeline":    sorted_timeline,
        "categories": [c.get("name", "") for c in categories],
        "cities":     [c.get("name", "") for c in cities],
        "doctors_list": doctors,
        "requests_list": reqs,
    }


# ─────────────────────────────────────────────
#  AUTH DECORATOR
# ─────────────────────────────────────────────

def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = session.get("jwt_token")
        if not token:
            app.logger.warning(f"Access denied to {request.path} - no token in session")
            return redirect(url_for("login"))
        return f(*args, **kwargs)
    return decorated


# ─────────────────────────────────────────────
#  ROUTES
# ─────────────────────────────────────────────

# ── Deny crawlers at the root level ──────────────────────────────────
@app.route("/robots.txt")
def robots():
    return "User-agent: *\nDisallow: /\n", 200, {"Content-Type": "text/plain"}

@app.route("/", defaults={"path": ""})
@app.route("/<path:path>")
def catch_all(path):
    """Return 404 for every URL that doesn't start with ADMIN_PREFIX."""
    return "", 404


@app.route(f"{ADMIN_PREFIX}/login", methods=["GET", "POST"])
def login():
    # If already logged in, redirect to dashboard
    if session.get("jwt_token"):
        app.logger.info("Already logged in, redirecting to dashboard")
        return redirect(url_for("dashboard"))
    
    error = None
    if request.method == "POST":
        email    = request.form.get("email", "").strip()
        password = request.form.get("password", "").strip()

        try:
            r = http.post(
                f"{BACKEND_URL}/api/auth/login/admin",
                json={"email": email, "password": password},
                timeout=REQUEST_TIMEOUT,
            )
            if r.status_code == 200:
                data = r.json()
                # Extract token - try different possible keys
                token = data.get("token") or data.get("accessToken")
                if not token and data:
                    # If neither key exists, try to get the first string value
                    token = next((v for v in data.values() if isinstance(v, str)), None)
                
                if not token:
                    error = "No authentication token received from backend"
                    app.logger.error(f"No token in response: {data}")
                else:
                    # Set session data - simpler approach
                    session["jwt_token"] = token
                    session["admin_email"] = email
                    session.permanent = True
                    
                    app.logger.info(f"Admin login successful: {email}")
                    return redirect(url_for("dashboard"))
            else:
                error = f"Invalid credentials (HTTP {r.status_code})"
                app.logger.warning(f"Login failed for {email}: HTTP {r.status_code}")
        except Exception as exc:
            app.logger.error(f"Login error: {exc}")
            error = f"Cannot reach backend: {exc}"
    return render_template_string(LOGIN_TEMPLATE, error=error)


@app.route(f"{ADMIN_PREFIX}/logout")
def logout():
    session.clear()
    response = redirect(url_for("login"))
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
    return response


@app.route(f"{ADMIN_PREFIX}/")
@login_required
def dashboard():
    token = session.get("jwt_token")
    if not token:
        # Defensive check - should not happen due to @login_required
        return redirect(url_for("login"))
    
    analytics = get_analytics(token)
    health    = get_all_health()
    return render_template_string(
        DASHBOARD_TEMPLATE,
        analytics=analytics,
        health=health,
        admin_email=session.get("admin_email", "Admin"),
        backend_url=BACKEND_URL,
        admin_prefix=ADMIN_PREFIX,
    )


# ── JSON API endpoints (used by dashboard AJAX) ──

@app.route(f"{ADMIN_PREFIX}/api/analytics")
@login_required
def api_analytics():
    return jsonify(get_analytics(session["jwt_token"]))


@app.route(f"{ADMIN_PREFIX}/api/health")
@login_required
def api_health():
    return jsonify(get_all_health())


@app.route(f"{ADMIN_PREFIX}/api/doctor/delete/<int:doctor_id>", methods=["POST"])
@login_required
def api_delete_doctor(doctor_id):
    status = _delete("/api/doctor/deleteByDoctorAdmin", params={"doctorId": doctor_id})
    if status in (200, 204):
        return jsonify({"success": True, "message": f"Doctor {doctor_id} deleted."})
    return jsonify({"success": False, "message": f"Backend returned HTTP {status}."}), 400


@app.route(f"{ADMIN_PREFIX}/api/doctors/list")
@login_required
def api_get_doctors():
    """Get all doctors with optional filters"""
    category = request.args.get("category")
    city = request.args.get("city")
    
    # Get all doctors
    data, status = _get("/api/doctor/getDoctors")
    if status != 200 or not data:
        return jsonify({"success": False, "doctors": []}), 200
    
    doctors = data if isinstance(data, list) else []
    
    # Apply filters if provided
    if category:
        doctors = [d for d in doctors if d.get("categoryName", "").lower() == category.lower()]
    if city:
        doctors = [d for d in doctors if d.get("cityName", "").lower() == city.lower()]
    
    return jsonify({"success": True, "doctors": doctors})


@app.route(f"{ADMIN_PREFIX}/api/doctor/<int:doctor_id>/view")
@login_required
def api_view_doctor(doctor_id):
    """Get full doctor details"""
    data, status = _get(f"/api/doctor/getDoctorById?doctorId={doctor_id}")
    if status == 200:
        return jsonify({"success": True, "doctor": data})
    return jsonify({"success": False, "message": f"HTTP {status}"}), 400


@app.route(f"{ADMIN_PREFIX}/api/doctor/<int:doctor_id>/update", methods=["POST"])
@login_required
def api_update_doctor(doctor_id):
    """Update doctor details"""
    request_data = request.get_json()
    if not request_data:
        return jsonify({"success": False, "message": "No data provided"}), 400
    
    # Ensure doctorId is set
    request_data["id"] = doctor_id
    
    data, status = _put("/api/doctor/updateDoctor", data=request_data)
    if status == 200:
        return jsonify({"success": True, "doctor": data, "message": "Doctor updated successfully"})
    return jsonify({"success": False, "message": f"Update failed: HTTP {status}"}), 400


@app.route(f"{ADMIN_PREFIX}/api/doctor/<int:doctor_id>/delete", methods=["POST"])
@login_required
def api_delete_doctor_admin(doctor_id):
    """Delete doctor by admin"""
    status = _delete("/api/doctor/deleteByDoctorAdmin", params={"doctorId": doctor_id})
    if status in (200, 204):
        return jsonify({"success": True, "message": f"Doctor {doctor_id} deleted successfully"})
    return jsonify({"success": False, "message": f"Delete failed: HTTP {status}"}), 400


# ── Export endpoints ──

@app.route(f"{ADMIN_PREFIX}/api/export/doctors")
@login_required
def export_doctors():
    """Export doctors list as CSV"""
    import csv
    from io import StringIO
    
    analytics = get_analytics(session.get("jwt_token"))
    doctors = analytics.get("doctors_list", [])
    
    output = StringIO()
    writer = csv.writer(output)
    
    # Write header
    writer.writerow(["ID", "First Name", "Last Name", "Email", "Phone", "Category", "City", "University", "Study Year"])
    
    # Write data
    for d in doctors:
        writer.writerow([
            d.get("id", ""),
            d.get("firstName", ""),
            d.get("lastName", ""),
            d.get("email", ""),
            d.get("phoneNumber", ""),
            d.get("categoryName", ""),
            d.get("cityName", ""),
            d.get("universityName", ""),
            d.get("studyYear", ""),
        ])
    
    output.seek(0)
    from flask import Response
    return Response(
        output.getvalue(),
        mimetype="text/csv",
        headers={"Content-Disposition": f"attachment; filename=doctors_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"}
    )


@app.route(f"{ADMIN_PREFIX}/api/export/requests")
@login_required
def export_requests():
    """Export requests list as CSV"""
    import csv
    from io import StringIO
    
    analytics = get_analytics(session.get("jwt_token"))
    requests_list = analytics.get("requests_list", [])
    
    output = StringIO()
    writer = csv.writer(output)
    
    # Write header
    writer.writerow(["ID", "Doctor Name", "Phone", "City", "University", "Category", "Status", "Date & Time", "Description"])
    
    # Write data
    for r in requests_list:
        # Handle both old and new format
        doctor_name = r.get("doctorName", "")
        if not doctor_name and (r.get("doctorFirstName") or r.get("doctorLastName")):
            doctor_name = f"{r.get('doctorFirstName', '')} {r.get('doctorLastName', '')}".strip()
        
        writer.writerow([
            r.get("id", ""),
            doctor_name,
            r.get("doctorPhoneNumber", ""),
            r.get("doctorCityName", ""),
            r.get("doctorUniversityName", ""),
            r.get("categoryName", ""),
            r.get("status", ""),
            r.get("dateTime", ""),
            r.get("description", ""),
        ])
    
    output.seek(0)
    from flask import Response
    return Response(
        output.getvalue(),
        mimetype="text/csv; charset=utf-8",
        headers={
            "Content-Disposition": f"attachment; filename=requests_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",
            "Content-Type": "text/csv; charset=utf-8"
        }
    )


@app.route(f"{ADMIN_PREFIX}/api/doctor/<int:doctor_id>")
@login_required
def get_doctor_details(doctor_id):
    """Get full doctor details"""
    data, status = _get(f"/api/doctor/getDoctorById?doctorId={doctor_id}")
    if status == 200:
        return jsonify({"success": True, "data": data})
    return jsonify({"success": False, "message": f"HTTP {status}"}), 400


# ─────────────────────────────────────────────
#  HTML TEMPLATES
# ─────────────────────────────────────────────

LOGIN_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Admin Login — Teeth Management System</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet"/>
  <style>
    body {
      min-height: 100vh;
      background: linear-gradient(135deg, #0d1117 0%, #161b22 100%);
      display: flex; align-items: center; justify-content: center;
    }
    .login-card {
      background: #1c2333;
      border: 1px solid #30363d;
      border-radius: 16px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.5);
      width: 100%; max-width: 420px; padding: 2.5rem;
    }
    .brand-icon { font-size: 3rem; color: #58a6ff; }
    .form-control {
      background: #0d1117; border-color: #30363d; color: #c9d1d9;
    }
    .form-control:focus {
      background: #0d1117; color: #c9d1d9; border-color: #58a6ff;
      box-shadow: 0 0 0 3px rgba(88,166,255,.2);
    }
    .btn-primary { background: #238636; border-color: #238636; }
    .btn-primary:hover { background: #2ea043; border-color: #2ea043; }
    label { color: #8b949e; }
    h2 { color: #f0f6fc; }
    small { color: #8b949e; }
  </style>
</head>
<body>
<div class="login-card">
  <div class="text-center mb-4">
    <div class="brand-icon"><i class="fa-solid fa-tooth"></i></div>
    <h2 class="mt-2 fw-bold">Admin Dashboard</h2>
    <small>Teeth Management System</small>
  </div>
  {% if error %}
  <div class="alert alert-danger py-2"><i class="fa fa-circle-exclamation me-2"></i>{{ error }}</div>
  {% endif %}
  <form method="POST">
    <div class="mb-3">
      <label class="form-label"><i class="fa fa-envelope me-1"></i>Admin Email</label>
      <input type="email" name="email" class="form-control" placeholder="admin@example.com" required autofocus/>
    </div>
    <div class="mb-4">
      <label class="form-label"><i class="fa fa-lock me-1"></i>Password</label>
      <input type="password" name="password" class="form-control" placeholder="••••••••" required/>
    </div>
    <button type="submit" class="btn btn-primary w-100 fw-semibold">
      <i class="fa fa-right-to-bracket me-2"></i>Sign In
    </button>
  </form>
</div>
</body>
</html>
"""


DASHBOARD_TEMPLATE = """
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title>Admin Dashboard — Teeth Management System</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet"/>
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <style>
    :root {
      --bg-base:    #0d1117;
      --bg-card:    #161b22;
      --bg-card2:   #1c2333;
      --border:     #30363d;
      --text-muted: #8b949e;
      --accent:     #58a6ff;
      --green:      #3fb950;
      --red:        #f85149;
      --yellow:     #d29922;
      --orange:     #e3b341;
    }
    * { box-sizing: border-box; }
    body { background: var(--bg-base); color: #c9d1d9; font-family: 'Segoe UI', system-ui, sans-serif; margin: 0; }

    /* ── Sidebar ── */
    .sidebar {
      position: fixed; top: 0; left: 0; bottom: 0; width: 240px;
      background: var(--bg-card); border-right: 1px solid var(--border);
      display: flex; flex-direction: column; z-index: 1000;
      padding-top: 1rem;
      transition: transform 0.3s ease;
    }
    .sidebar.mobile-hidden { transform: translateX(-100%); }
    .sidebar .brand {
      padding: 1rem 1.5rem 1.5rem;
      border-bottom: 1px solid var(--border);
      color: var(--accent); font-size: 1.1rem; font-weight: 700;
    }
    .sidebar .brand i { margin-right: .5rem; }
    .sidebar .nav-link {
      color: var(--text-muted); padding: .6rem 1.5rem;
      border-radius: 0; transition: all .2s;
    }
    .sidebar .nav-link:hover, .sidebar .nav-link.active {
      color: #f0f6fc; background: var(--bg-card2);
      border-left: 3px solid var(--accent);
    }
    .sidebar .nav-link i { width: 20px; margin-right: .6rem; }
    .sidebar-bottom { margin-top: auto; padding: 1rem 1.5rem; border-top: 1px solid var(--border); }

    /* ── Mobile Menu Toggle ── */
    .mobile-menu-toggle {
      display: none;
      position: fixed; top: 1rem; left: 1rem; z-index: 1001;
      background: var(--bg-card); border: 1px solid var(--border);
      border-radius: 8px; width: 44px; height: 44px;
      align-items: center; justify-content: center;
      cursor: pointer; box-shadow: 0 4px 12px rgba(0,0,0,0.3);
      transition: all .2s;
    }
    .mobile-menu-toggle:hover { background: var(--bg-card2); }
    .mobile-menu-toggle i { color: var(--accent); font-size: 1.25rem; }
    
    .mobile-overlay {
      display: none;
      position: fixed; top: 0; left: 0; right: 0; bottom: 0;
      background: rgba(0,0,0,0.7); z-index: 999;
      opacity: 0; transition: opacity 0.3s;
    }
    .mobile-overlay.show { opacity: 1; }

    /* ── Main ── */
    .main { margin-left: 240px; padding: 2rem; min-height: 100vh; }
    .page-header {
      background: var(--bg-card); border: 1px solid var(--border);
      border-radius: 12px; padding: 1.2rem 1.5rem; margin-bottom: 2rem;
      display: flex; align-items: center; justify-content: space-between;
      flex-wrap: wrap; gap: 1rem;
    }
    .page-header h4 { margin: 0; color: #f0f6fc; font-weight: 700; }

    /* ── Stat cards ── */
    .stat-card {
      background: var(--bg-card); border: 1px solid var(--border);
      border-radius: 12px; padding: 1.4rem; transition: transform .2s;
    }
    .stat-card:hover { transform: translateY(-3px); }
    .stat-card .stat-icon {
      width: 48px; height: 48px; border-radius: 10px;
      display: flex; align-items: center; justify-content: center; font-size: 1.4rem;
    }
    .stat-card .stat-value { font-size: 2rem; font-weight: 700; color: #f0f6fc; }
    .stat-card .stat-label { color: var(--text-muted); font-size: .85rem; }

    /* ── Chart cards ── */
    .chart-card {
      background: var(--bg-card); border: 1px solid var(--border);
      border-radius: 12px; padding: 1.4rem; height: 100%;
    }
    .chart-card h6 {
      color: #f0f6fc; font-weight: 700; margin-bottom: 1rem;
      padding-bottom: .6rem; border-bottom: 1px solid var(--border);
    }

    /* ── Health panel ── */
    .health-row { margin-bottom: 1rem; }
    .health-badge {
      display: inline-flex; align-items: center; gap: .4rem;
      padding: .3rem .8rem; border-radius: 20px; font-size: .82rem; font-weight: 600;
    }
    .hb-healthy { background: rgba(63,185,80,.15); color: var(--green); border: 1px solid rgba(63,185,80,.3); }
    .hb-error, .hb-unhealthy, .hb-unreachable {
      background: rgba(248,81,73,.15); color: var(--red); border: 1px solid rgba(248,81,73,.3);
    }
    .hb-unknown { background: rgba(139,148,158,.15); color: var(--text-muted); border: 1px solid var(--border); }
    .service-card {
      background: var(--bg-card2); border: 1px solid var(--border);
      border-radius: 10px; padding: 1rem 1.2rem;
    }
    .service-name { font-weight: 600; color: #f0f6fc; margin-bottom: .3rem; }
    .service-detail { font-size: .8rem; color: var(--text-muted); }

    /* ── Tables ── */
    .data-card {
      background: var(--bg-card); border: 1px solid var(--border);
      border-radius: 12px; overflow: hidden; margin-bottom: 1.5rem;
    }
    .data-card .card-head {
      padding: 1rem 1.5rem; border-bottom: 1px solid var(--border);
      background: var(--bg-card2);
      display: flex; align-items: center; justify-content: space-between;
      flex-wrap: wrap; gap: 0.75rem;
    }
    .data-card .card-head > div { flex-wrap: wrap; }
    .data-card .card-head h6 { margin: 0; font-weight: 700; color: #f0f6fc; }
    table { margin: 0; }
    thead { background: var(--bg-card2); }
    th { font-size: .8rem; text-transform: uppercase; color: var(--text-muted); letter-spacing: .05em; }
    td, th { border-color: var(--border) !important; padding: .65rem 1rem !important; }
    tbody tr:hover { background: rgba(88,166,255,.05); }
    .table-responsive { overflow-x: auto; -webkit-overflow-scrolling: touch; }
    
    /* Support for RTL text (Arabic, etc.) */
    td, th, .card-value, .modal-value { 
      direction: auto; 
      unicode-bidi: plaintext; 
    }
    
    @media(max-width:992px) {
      table { font-size: .85rem; }
      td, th { padding: .5rem .6rem !important; white-space: nowrap; }
    }
    
    /* ── Mobile Card View ── */
    .mobile-card-view {
      display: none;
      padding: 1rem;
    }
    .data-item-card {
      background: var(--bg-card2);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 1rem;
      margin-bottom: 0.75rem;
      transition: all 0.2s;
    }
    .data-item-card:hover {
      border-color: var(--accent);
      transform: translateY(-2px);
    }
    .card-row {
      display: flex;
      justify-content: space-between;
      padding: 0.4rem 0;
      border-bottom: 1px solid var(--border);
    }
    .card-row:last-child {
      border-bottom: none;
    }
    .card-label {
      font-weight: 600;
      color: var(--text-muted);
      font-size: 0.85rem;
    }
    .card-value {
      color: #f0f6fc;
      text-align: right;
      font-size: 0.85rem;
    }
    @media(max-width:768px) {
      .table-responsive { display: none; }
      .mobile-card-view { display: block; }
    }

    /* ── Quick Stats ── */
    .quick-stat-card {
      padding: 1rem;
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: 8px;
      transition: all 0.2s;
    }
    .quick-stat-card:hover {
      transform: translateY(-2px);
      border-color: var(--accent);
    }

    /* ── Misc ── */
    .section { display: none; }
    .section.active { display: block; }
    .refresh-btn { cursor: pointer; }
    .refresh-btn.refreshing #manual-refresh-icon { animation: spin 1s linear infinite; }
    @keyframes spin { to { transform: rotate(360deg); } }
    #auto-refresh-toggle.active { background-color: var(--green); border-color: var(--green); color: white; }
    .refreshing-indicator {
      position: fixed; top: 70px; right: 20px; z-index: 500;
      background: var(--bg-card); border: 1px solid var(--accent);
      border-radius: 8px; padding: 0.5rem 1rem;
      box-shadow: 0 4px 12px rgba(88,166,255,0.3);
      display: none; align-items: center; gap: 0.5rem;
      animation: slideInRight 0.3s;
    }
    @keyframes slideInRight { from { transform: translateX(100%); } to { transform: translateX(0); } }
    .refreshing-indicator.show { display: flex; }
    .refresh-spinner { 
      width: 14px; height: 14px; 
      border: 2px solid var(--accent);
      border-top-color: transparent;
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
    }
    .dot-pulse { display: inline-block; width: 8px; height: 8px; border-radius: 50%; }
    .dot-green { background: var(--green); }
    .dot-red   { background: var(--red); }
    .dot-yellow{ background: var(--yellow); }
    .dot-grey  { background: var(--text-muted); }
    #last-updated { font-size: .75rem; color: var(--text-muted); display: block; }
    .delete-btn { padding: .2rem .6rem; font-size: .78rem; }
    .badge-pending  { background: rgba(210,153,34,.2);  color: var(--orange); border: 1px solid rgba(210,153,34,.3); }
    .badge-approved { background: rgba(63,185,80,.2);   color: var(--green);  border: 1px solid rgba(63,185,80,.3); }
    .badge-rejected { background: rgba(248,81,73,.2);   color: var(--red);    border: 1px solid rgba(248,81,73,.3); }
    .badge-unknown  { background: rgba(139,148,158,.15); color: var(--text-muted); border: 1px solid var(--border); }

    /* ── Modals ── */
    .modal-overlay {
      position: fixed; top: 0; left: 0; right: 0; bottom: 0; z-index: 9999;
      background: rgba(0,0,0,0.8); display: flex; align-items: center; justify-content: center;
      opacity: 0; pointer-events: none; transition: opacity .2s;
    }
    .modal-overlay.show { opacity: 1; pointer-events: all; }
    .modal-content {
      background: var(--bg-card); border: 1px solid var(--border);
      border-radius: 12px; max-width: 600px; width: 90%; max-height: 80vh;
      overflow-y: auto; padding: 1.5rem; transform: scale(0.9); transition: transform .2s;
    }
    .modal-overlay.show .modal-content { transform: scale(1); }
    .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; }
    .modal-header h5 { margin: 0; color: #f0f6fc; }
    .modal-close { background: none; border: none; color: var(--text-muted); font-size: 1.5rem;
      cursor: pointer; padding: 0; width: 32px; height: 32px; }
    .modal-close:hover { color: #f0f6fc; }
    .modal-body { color: #c9d1d9; }
    .modal-row { display: flex; padding: .75rem 0; border-bottom: 1px solid var(--border); }
    .modal-row:last-child { border-bottom: none; }
    .modal-label { font-weight: 600; color: var(--text-muted); width: 140px; flex-shrink: 0; }
    .modal-value { color: #f0f6fc; flex: 1; }

    /* ── Toast Notifications ── */
    .toast-container {
      position: fixed; top: 20px; right: 20px; z-index: 10000;
      display: flex; flex-direction: column; gap: 10px; max-width: 400px;
    }
    .toast {
      background: var(--bg-card2); border: 1px solid var(--border); border-radius: 8px;
      padding: 1rem 1.25rem; display: flex; align-items: center; gap: 12px;
      box-shadow: 0 8px 24px rgba(0,0,0,0.4); transform: translateX(120%);
      animation: slideIn .3s forwards;
    }
    @keyframes slideIn { to { transform: translateX(0); } }
    .toast.hiding { animation: slideOut .3s forwards; }
    @keyframes slideOut { to { transform: translateX(120%); } }
    .toast-icon { font-size: 1.25rem; }
    .toast.toast-success { border-left: 4px solid var(--green); }
    .toast.toast-success .toast-icon { color: var(--green); }
    .toast.toast-error { border-left: 4px solid var(--red); }
    .toast.toast-error .toast-icon { color: var(--red); }
    .toast.toast-info { border-left: 4px solid var(--accent); }
    .toast.toast-info .toast-icon { color: var(--accent); }
    .toast-message { flex: 1; color: #f0f6fc; font-size: .9rem; }

    /* ── Dark Mode Toggle ── */
    .theme-toggle {
      position: fixed; bottom: 20px; right: 20px; z-index: 500;
      background: var(--bg-card); border: 1px solid var(--border);
      border-radius: 50%; width: 48px; height: 48px;
      display: flex; align-items: center; justify-content: center;
      cursor: pointer; box-shadow: 0 4px 12px rgba(0,0,0,0.3);
      transition: all .2s;
    }
    .theme-toggle:hover { transform: scale(1.1); background: var(--bg-card2); }
    .theme-toggle i { color: var(--accent); font-size: 1.25rem; }
    
    body.light-mode {
      --bg-base: #f5f7fa; --bg-card: #ffffff; --bg-card2: #f8f9fa;
      --border: #dee2e6; --text-muted: #6c757d; --accent: #0366d6;
    }
    body.light-mode { background: var(--bg-base); color: #212529; }
    body.light-mode .sidebar, body.light-mode .stat-card, body.light-mode .chart-card,
    body.light-mode .data-card, body.light-mode .service-card,
    body.light-mode .modal-content, body.light-mode .data-item-card { color: #212529; }
    body.light-mode .nav-link { color: #6c757d; }
    body.light-mode .nav-link:hover, body.light-mode .nav-link.active { color: #212529; }
    body.light-mode h4, body.light-mode h5, body.light-mode h6,
    body.light-mode .stat-value, body.light-mode .modal-value, 
    body.light-mode .card-value { color: #212529; }
    body.light-mode .toast { background: #ffffff; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
    body.light-mode .mobile-menu-toggle { color: #212529; }
    body.light-mode .mobile-overlay { background: rgba(0,0,0,0.4); }

    /* ── Mobile Responsive ── */
    @media(max-width:768px){
      .mobile-menu-toggle { display: flex; }
      .mobile-overlay.show { display: block; }
      .sidebar { 
        transform: translateX(-100%);
        box-shadow: 4px 0 12px rgba(0,0,0,0.5);
      }
      .sidebar.show { transform: translateX(0); }
      .main { margin-left: 0; padding: 1rem; padding-top: 4rem; }
      .theme-toggle { bottom: 80px; right: 15px; width: 44px; height: 44px; }
      
      .page-header { padding: 1rem; }
      .page-header h4 { font-size: 1.1rem; width: 100%; }
      .page-header > div:first-child { width: 100%; margin-bottom: 0.75rem; }
      .page-header .d-flex { width: 100%; justify-content: stretch; }
      .page-header .btn { flex: 1; }
      
      .refreshing-indicator { top: 60px; right: 10px; font-size: 0.8rem; padding: 0.4rem 0.75rem; }
      
      .stat-card { padding: 1rem; }
      .stat-value { font-size: 1.5rem; }
      .stat-label { font-size: .75rem; }
      .stat-icon { width: 40px; height: 40px; font-size: 1.1rem; }
      
      .chart-card { padding: 1rem; }
      .chart-card h6 { font-size: .9rem; }
      
      .data-card .card-head { padding: .75rem 1rem; flex-direction: column; align-items: flex-start; }
      .data-card .card-head > div { width: 100%; }
      .data-card .card-head .d-flex { flex-direction: column; gap: 0.5rem !important; }
      .data-card .card-head select,
      .data-card .card-head input,
      .data-card .card-head .btn { width: 100% !important; max-width: 100% !important; }
      
      .service-card { padding: .85rem 1rem; }
      .service-name { font-size: .9rem; }
      .service-detail { font-size: .75rem; }
      .health-badge { font-size: .75rem; padding: .25rem .6rem; }
      
      .modal-content { width: 95%; padding: 1.25rem; max-height: 85vh; }
      .modal-row { flex-direction: column; padding: .5rem 0; }
      .modal-label { width: 100%; margin-bottom: .25rem; font-size: .85rem; }
      .modal-value { font-size: .9rem; }
      
      .toast-container { right: 10px; left: 10px; max-width: 100%; }
      .toast { font-size: .85rem; padding: .75rem 1rem; }
      
      /* Better button spacing on mobile */
      .btn-group { display: flex; gap: 0.25rem; }
      .btn-sm { padding: .35rem .6rem; font-size: .8rem; }
      
      /* Stack columns on mobile */
      .row.g-3 > [class*="col-"] { margin-bottom: 1rem; }
    }
    
    @media(max-width:576px){
      .stat-card .d-flex { flex-direction: column; align-items: flex-start !important; gap: 0.5rem; }
      .stat-icon { margin-bottom: .5rem; }
      
      .quick-stat-card h4 { font-size: 1.25rem; }
      .quick-stat-card small { font-size: 0.7rem; }
      
      table { font-size: .75rem; }
      td, th { padding: .4rem .5rem !important; }
      .badge { font-size: .7rem; padding: .2rem .4rem; }
      
      .btn { font-size: .8rem; padding: .4rem .7rem; }
      .btn-sm { font-size: .72rem; padding: .3rem .5rem; }
      
      .page-header h4 { font-size: 1rem; }
      .chart-card h6 { font-size: .85rem; }
    }
  </style>
</head>
<body>

<!-- Mobile Menu Toggle -->
<div class="mobile-menu-toggle" onclick="toggleMobileMenu()">
  <i class="fa fa-bars"></i>
</div>

<!-- Mobile Overlay -->
<div class="mobile-overlay" id="mobile-overlay" onclick="closeMobileMenu()"></div>

<!-- ═══════════════ SIDEBAR ═══════════════ -->
<div class="sidebar" id="sidebar">
  <div class="brand"><i class="fa-solid fa-tooth"></i>TMS Admin</div>
  <nav class="nav flex-column mt-2">
    <a class="nav-link active" data-section="overview" href="#" onclick="showSection('overview',this)">
      <i class="fa-solid fa-gauge-high"></i>Overview
    </a>
    <a class="nav-link" data-section="doctors" href="#" onclick="showSection('doctors',this)">
      <i class="fa-solid fa-user-doctor"></i>Doctors
    </a>
    <a class="nav-link" data-section="requests" href="#" onclick="showSection('requests',this)">
      <i class="fa-solid fa-file-medical"></i>Requests
    </a>
    <a class="nav-link" data-section="health" href="#" onclick="showSection('health',this)">
      <i class="fa-solid fa-server"></i>Service Health
    </a>
  </nav>
  <div class="sidebar-bottom">
    <div class="d-flex align-items-center gap-2 mb-2">
      <i class="fa-solid fa-circle-user text-secondary"></i>
      <small class="text-muted text-truncate">{{ admin_email }}</small>
    </div>
    <a href="{{ admin_prefix }}/logout" class="btn btn-sm btn-outline-danger w-100">
      <i class="fa-solid fa-right-from-bracket me-1"></i>Logout
    </a>
  </div>
</div>

<!-- ═══════════════ MAIN CONTENT ═══════════════ -->
<div class="main">

  <!-- Page header -->
  <div class="page-header">
    <div>
      <h4><i class="fa-solid fa-chart-line me-2 text-info"></i>Analytics Dashboard</h4>
      <span id="last-updated">Last updated: —</span>
    </div>
    <div class="d-flex gap-2 align-items-center">
      <button class="btn btn-sm btn-outline-secondary" id="auto-refresh-toggle" onclick="toggleAutoRefresh()" title="Toggle Auto-Refresh">
        <i class="fa-solid fa-pause" id="refresh-icon"></i>
        <span class="d-none d-md-inline ms-1" id="refresh-text">Pause</span>
      </button>
      <button class="btn btn-sm btn-outline-secondary refresh-btn" onclick="refreshAll()">
        <i class="fa-solid fa-rotate-right me-1" id="manual-refresh-icon"></i>
        <span class="d-none d-sm-inline">Refresh</span>
      </button>
    </div>
  </div>

  <!-- ── OVERVIEW SECTION ── -->
  <div id="section-overview" class="section active">

    <!-- Stat cards -->
    <div class="row g-3 mb-4">
      <div class="col-6 col-md-3">
        <div class="stat-card">
          <div class="d-flex align-items-center justify-content-between">
            <div>
              <div class="stat-value" id="total-doctors">{{ analytics.totals.doctors }}</div>
              <div class="stat-label">Total Doctors</div>
            </div>
            <div class="stat-icon" style="background:rgba(88,166,255,.15);color:#58a6ff">
              <i class="fa-solid fa-user-doctor"></i>
            </div>
          </div>
        </div>
      </div>
      <div class="col-6 col-md-3">
        <div class="stat-card">
          <div class="d-flex align-items-center justify-content-between">
            <div>
              <div class="stat-value" id="total-requests">{{ analytics.totals.requests }}</div>
              <div class="stat-label">Total Requests</div>
            </div>
            <div class="stat-icon" style="background:rgba(63,185,80,.15);color:#3fb950">
              <i class="fa-solid fa-file-medical"></i>
            </div>
          </div>
        </div>
      </div>
      <div class="col-6 col-md-3">
        <div class="stat-card">
          <div class="d-flex align-items-center justify-content-between">
            <div>
              <div class="stat-value" id="total-categories">{{ analytics.totals.categories }}</div>
              <div class="stat-label">Categories</div>
            </div>
            <div class="stat-icon" style="background:rgba(227,179,65,.15);color:#e3b341">
              <i class="fa-solid fa-tag"></i>
            </div>
          </div>
        </div>
      </div>
      <div class="col-6 col-md-3">
        <div class="stat-card">
          <div class="d-flex align-items-center justify-content-between">
            <div>
              <div class="stat-value" id="total-cities">{{ analytics.totals.cities }}</div>
              <div class="stat-label">Cities</div>
            </div>
            <div class="stat-icon" style="background:rgba(188,140,255,.15);color:#bc8cff">
              <i class="fa-solid fa-city"></i>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Quick Stats Row -->
    <div class="row g-3 mb-4">
      <div class="col-6 col-md-3">
        <div class="quick-stat-card">
          <div class="d-flex align-items-center justify-content-between mb-2">
            <small class="text-muted"><i class="fa fa-chart-line me-1"></i>Pending Requests</small>
          </div>
          <h4 class="mb-0" id="stat-pending">{{ analytics.requests_by_status.get('PENDING', 0) }}</h4>
        </div>
      </div>
      <div class="col-6 col-md-3">
        <div class="quick-stat-card">
          <div class="d-flex align-items-center justify-content-between mb-2">
            <small class="text-muted"><i class="fa fa-check-circle me-1"></i>Approved</small>
          </div>
          <h4 class="mb-0 text-success" id="stat-approved">{{ analytics.requests_by_status.get('APPROVED', 0) }}</h4>
        </div>
      </div>
      <div class="col-6 col-md-3">
        <div class="quick-stat-card">
          <div class="d-flex align-items-center justify-content-between mb-2">
            <small class="text-muted"><i class="fa fa-times-circle me-1"></i>Rejected</small>
          </div>
          <h4 class="mb-0 text-danger" id="stat-rejected">{{ analytics.requests_by_status.get('REJECTED', 0) }}</h4>
        </div>
      </div>
      <div class="col-6 col-md-3">
        <div class="quick-stat-card">
          <div class="d-flex align-items-center justify-content-between mb-2">
            <small class="text-muted"><i class="fa fa-graduation-cap me-1"></i>Universities</small>
          </div>
          <h4 class="mb-0" id="stat-universities">{{ analytics.doctors_by_university | length }}</h4>
        </div>
      </div>
    </div>

    <!-- Charts row 1 -->
    <div class="row g-3 mb-3">
      <div class="col-md-6">
        <div class="chart-card">
          <h6><i class="fa-solid fa-chart-bar me-2 text-info"></i>Doctors by Category</h6>
          <canvas id="chartDoctorCategory" height="220"></canvas>
        </div>
      </div>
      <div class="col-md-6">
        <div class="chart-card">
          <h6><i class="fa-solid fa-chart-pie me-2 text-warning"></i>Doctors by City</h6>
          <canvas id="chartDoctorCity" height="220"></canvas>
        </div>
      </div>
    </div>

    <!-- Charts row 2 -->
    <div class="row g-3 mb-3">
      <div class="col-md-4">
        <div class="chart-card">
          <h6><i class="fa-solid fa-circle-half-stroke me-2 text-success"></i>Requests by Status</h6>
          <canvas id="chartRequestStatus" height="220"></canvas>
        </div>
      </div>
      <div class="col-md-4">
        <div class="chart-card">
          <h6><i class="fa-solid fa-chart-bar me-2 text-danger"></i>Requests by Category</h6>
          <canvas id="chartRequestCategory" height="220"></canvas>
        </div>
      </div>
      <div class="col-md-4">
        <div class="chart-card">
          <h6><i class="fa-solid fa-university me-2 text-info"></i>Doctors by University</h6>
          <canvas id="chartDoctorUniversity" height="220"></canvas>
        </div>
      </div>
    </div>

    <!-- Request timeline -->
    <div class="row g-3 mb-3">
      <div class="col-12">
        <div class="chart-card">
          <h6><i class="fa-solid fa-chart-line me-2 text-primary"></i>Request Activity Over Time</h6>
          <canvas id="chartTimeline" height="100"></canvas>
        </div>
      </div>
    </div>

    <!-- Mini health strip -->
    <div class="row g-3">
      <div class="col-12">
        <div class="chart-card">
          <h6><i class="fa-solid fa-server me-2 text-secondary"></i>Service Health Snapshot
            <button class="btn btn-sm btn-outline-secondary ms-2 py-0 px-2" onclick="loadHealth()">
              <i class="fa-solid fa-rotate-right"></i>
            </button>
          </h6>
          <div id="health-strip" class="d-flex flex-wrap gap-3 mt-1">
            <!-- filled by JS -->
          </div>
        </div>
      </div>
    </div>
  </div><!-- /overview -->

  <!-- ── DOCTORS SECTION ── -->
  <div id="section-doctors" class="section">
    <div class="data-card">
      <div class="card-head">
        <div class="d-flex align-items-center gap-2">
          <h6 class="mb-0"><i class="fa-solid fa-user-doctor me-2 text-info"></i>All Registered Doctors
            <span class="badge bg-secondary ms-2" id="doctors-count"></span>
          </h6>
        </div>
        <div class="d-flex align-items-center gap-2">
          <select id="filter-category" class="form-select form-select-sm" style="width:150px" onchange="applyDoctorFilters()">
            <option value="">All Categories</option>
            {% for cat in analytics.categories %}
            <option value="{{ cat }}">{{ cat }}</option>
            {% endfor %}
          </select>
          <select id="filter-city" class="form-select form-select-sm" style="width:140px" onchange="applyDoctorFilters()">
            <option value="">All Cities</option>
            {% for city in analytics.cities %}
            <option value="{{ city }}">{{ city }}</option>
            {% endfor %}
          </select>
          <input type="text" id="doctor-search" class="form-control form-control-sm"
                 style="width:200px" placeholder="🔍 Search…" oninput="applyDoctorFilters()">
          <button class="btn btn-sm btn-outline-secondary" onclick="clearDoctorFilters()" title="Clear Filters">
            <i class="fa fa-times"></i>
          </button>
          <button class="btn btn-sm btn-success" onclick="exportDoctors()" title="Export to CSV">
            <i class="fa fa-download me-1"></i>Export CSV
          </button>
        </div>
      </div>
      <div class="table-responsive">
        <table class="table table-hover table-sm" id="doctor-table">
          <thead>
            <tr>
              <th>#</th><th>Name</th><th>Category</th><th>City</th>
              <th>University</th><th>Study Year</th><th>Phone</th><th>Actions</th>
            </tr>
          </thead>
          <tbody id="doctor-tbody">
            {% for d in analytics.doctors_list %}
            <tr data-id="{{ d.get('id', '') }}" data-doctor='{{ d | tojson }}'>
              <td>{{ loop.index }}</td>
              <td>{{ d.firstName or '' }} {{ d.lastName or '' }}</td>
              <td><span class="badge bg-info text-dark">{{ d.categoryName or '—' }}</span></td>
              <td>{{ d.cityName or '—' }}</td>
              <td>{{ d.universityName or '—' }}</td>
              <td>{{ d.studyYear or '—' }}</td>
              <td>{{ d.phoneNumber or '—' }}</td>
              <td>
                {% if d.get('id') %}
                <div class="btn-group btn-group-sm">
                  <button class="btn btn-outline-primary" onclick="viewDoctor({{ d.id }})" title="View Details">
                    <i class="fa fa-eye"></i>
                  </button>
                  <button class="btn btn-outline-danger" onclick="deleteDoctor({{ d.id }}, this)" title="Delete">
                    <i class="fa fa-trash"></i>
                  </button>
                </div>
                {% else %}<span class="text-muted">—</span>{% endif %}
              </td>
            </tr>
            {% else %}
            <tr><td colspan="8" class="text-center text-muted py-4">No doctors found</td></tr>
            {% endfor %}
          </tbody>
        </table>
      </div>
      <!-- Mobile Card View -->
      <div class="mobile-card-view" id="doctor-cards">
        {% for d in analytics.doctors_list %}
        <div class="data-item-card" data-doctor-card data-id="{{ d.get('id', '') }}">
          <div class="card-row">
            <span class="card-label"><i class="fa fa-user me-1"></i>Name</span>
            <span class="card-value"><strong>{{ d.firstName or '' }} {{ d.lastName or '' }}</strong></span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-tag me-1"></i>Category</span>
            <span class="card-value"><span class="badge bg-info text-dark">{{ d.categoryName or '—' }}</span></span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-location-dot me-1"></i>City</span>
            <span class="card-value">{{ d.cityName or '—' }}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-university me-1"></i>University</span>
            <span class="card-value">{{ d.universityName or '—' }}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-graduation-cap me-1"></i>Study Year</span>
            <span class="card-value">{{ d.studyYear or '—' }}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-phone me-1"></i>Phone</span>
            <span class="card-value">{{ d.phoneNumber or '—' }}</span>
          </div>
          {% if d.get('id') %}
          <div class="d-flex gap-2 mt-3">
            <button class="btn btn-sm btn-outline-primary flex-fill" onclick=\"viewDoctor({{ d.id }})\" title=\"View Details\">
              <i class="fa fa-eye me-1"></i>View
            </button>
            <button class="btn btn-sm btn-outline-danger flex-fill" onclick=\"deleteDoctor({{ d.id }}, this)\" title=\"Delete\">
              <i class="fa fa-trash me-1"></i>Delete
            </button>
          </div>
          {% endif %}
        </div>
        {% else %}
        <div class="text-center text-muted py-4">No doctors found</div>
        {% endfor %}
      </div>
    </div>
  </div><!-- /doctors -->

  <!-- ── REQUESTS SECTION ── -->
  <div id="section-requests" class="section">
    <div class="data-card">
      <div class="card-head">
        <div class="d-flex align-items-center gap-2">
          <h6 class="mb-0"><i class="fa-solid fa-file-medical me-2 text-success"></i>All Service Requests
            <span class="badge bg-secondary ms-2" id="requests-count"></span>
          </h6>
        </div>
        <div class="d-flex align-items-center gap-2">
          <input type="text" id="request-search" class="form-control form-control-sm"
                 style="width:200px" placeholder="🔍 Search…" oninput="filterTable('request-table',this.value)">
          <button class="btn btn-sm btn-success" onclick="exportRequests()" title="Export to CSV">
            <i class="fa fa-download me-1"></i>Export CSV
          </button>
        </div>
      </div>
      <div class="table-responsive">
        <table class="table table-hover table-sm" id="request-table">
          <thead>
            <tr>
              <th>#</th><th>ID</th><th>Doctor</th><th>Phone</th><th>City</th>
              <th>Category</th><th>Status</th><th>Date &amp; Time</th><th>Description</th>
            </tr>
          </thead>
          <tbody>
            {% for r in analytics.requests_list %}
            <tr>
              <td>{{ loop.index }}</td>
              <td>{{ r.id or '—' }}</td>
              <td>{{ (r.doctorFirstName or '') + ' ' + (r.doctorLastName or '') if r.get('doctorFirstName') else (r.doctorName or '—') }}</td>
              <td>{{ r.doctorPhoneNumber or '—' }}</td>
              <td>{{ r.doctorCityName or '—' }}</td>
              <td>{{ r.categoryName or '—' }}</td>
              <td>
                {% set s = (r.status or 'UNKNOWN')|upper %}
                {% if s == 'PENDING' %}
                  <span class="badge badge-pending">⏳ Pending</span>
                {% elif s == 'APPROVED' %}
                  <span class="badge badge-approved">✅ Approved</span>
                {% elif s == 'REJECTED' %}
                  <span class="badge badge-rejected">❌ Rejected</span>
                {% else %}
                  <span class="badge badge-unknown">{{ s }}</span>
                {% endif %}
              </td>
              <td>{{ r.dateTime or '—' }}</td>
              <td class="text-muted" style="max-width:250px;white-space:normal">
                {{ r.description or '—' }}
              </td>
            </tr>
            {% else %}
            <tr><td colspan="9" class="text-center text-muted py-4">No requests found</td></tr>
            {% endfor %}
          </tbody>
        </table>
      </div>
      <!-- Mobile Card View -->
      <div class="mobile-card-view" id="request-cards">
        {% for r in analytics.requests_list %}
        <div class="data-item-card" data-request-card>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-hashtag me-1"></i>ID</span>
            <span class="card-value"><strong>{{ r.id or '—' }}</strong></span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-user-doctor me-1"></i>Doctor</span>
            <span class="card-value">{{ (r.doctorFirstName or '') + ' ' + (r.doctorLastName or '') if r.get('doctorFirstName') else (r.doctorName or '—') }}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-phone me-1"></i>Phone</span>
            <span class="card-value">{{ r.doctorPhoneNumber or '—' }}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-location-dot me-1"></i>City</span>
            <span class="card-value">{{ r.doctorCityName or '—' }}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-university me-1"></i>University</span>
            <span class="card-value">{{ r.doctorUniversityName or '—' }}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-tag me-1"></i>Category</span>
            <span class="card-value">{{ r.categoryName or '—' }}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-clock me-1"></i>Status</span>
            <span class="card-value">
              {% set s = (r.status or 'UNKNOWN')|upper %}
              {% if s == 'PENDING' %}
              <span class="badge badge-pending">⏳ Pending</span>
              {% elif s == 'APPROVED' %}
              <span class="badge badge-approved">✅ Approved</span>
              {% elif s == 'REJECTED' %}
              <span class="badge badge-rejected">❌ Rejected</span>
              {% else %}
              <span class="badge badge-unknown">{{ s }}</span>
              {% endif %}
            </span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-calendar me-1"></i>Date & Time</span>
            <span class="card-value">{{ r.dateTime or '—' }}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-file-text me-1"></i>Description</span>
            <span class="card-value text-muted" style="text-align: left; font-size: 0.8rem;">{{ r.description or '—' }}</span>
          </div>
        </div>
        {% else %}
        <div class="text-center text-muted py-4">No requests found</div>
        {% endfor %}
      </div>
    </div>
  </div><!-- /requests -->

  <!-- ── HEALTH SECTION ── -->
  <div id="section-health" class="section">
    <div class="row g-3 mb-3">

      <!-- Backend -->
      <div class="col-md-6">
        <div class="service-card">
          <div class="service-name"><i class="fa-brands fa-java me-2 text-warning"></i>Spring Boot Backend</div>
          <div class="service-detail mb-2">{{ backend_url }}</div>
          {% set b = health.backend %}
          {% if b.status == 'healthy' %}
            <span class="health-badge hb-healthy"><i class="fa fa-circle-check"></i>Healthy (HTTP {{ b.code }})</span>
          {% elif b.status == 'unhealthy' %}
            <span class="health-badge hb-unhealthy"><i class="fa fa-triangle-exclamation"></i>Unhealthy (HTTP {{ b.code }})</span>
          {% else %}
            <span class="health-badge hb-error"><i class="fa fa-circle-xmark"></i>Unreachable — {{ b.get('error','') }}</span>
          {% endif %}
        </div>
      </div>

      <!-- AI Chatbot -->
      <div class="col-md-6">
        <div class="service-card">
          <div class="service-name"><i class="fa-solid fa-robot me-2 text-info"></i>AI Chatbot API</div>
          <div class="service-detail mb-2">{{ "http://127.0.0.1:5010" }}</div>
          {% set a = health.ai_chatbot %}
          {% if a.status == 'ok' %}
            <span class="health-badge hb-healthy"><i class="fa fa-circle-check"></i>Online</span>
            <span class="ms-2 service-detail">
              AI: {% if a.ai_initialized %}✅{% else %}❌{% endif %}
              &nbsp;|&nbsp; Questions: {% if a.questions_loaded %}✅{% else %}❌{% endif %}
            </span>
          {% else %}
            <span class="health-badge hb-error"><i class="fa fa-circle-xmark"></i>
              {{ a.get('error', a.status) }}
            </span>
          {% endif %}
        </div>
      </div>

      <!-- OTP System -->
      <div class="col-md-6">
        <div class="service-card">
          <div class="service-name"><i class="fa-solid fa-mobile-screen me-2 text-success"></i>OTP / WhatsApp System</div>
          <div class="service-detail mb-2">{{ "http://127.0.0.1:8000" }}</div>
          {% set o = health.otp_system %}
          {% if o.status == 'healthy' %}
            <span class="health-badge hb-healthy"><i class="fa fa-circle-check"></i>Healthy</span>
            {% if o.get('timestamp') %}
              <span class="ms-2 service-detail">Last check: {{ o.timestamp }}</span>
            {% endif %}
          {% else %}
            <span class="health-badge hb-error"><i class="fa fa-circle-xmark"></i>
              {{ o.get('error', o.status) }}
            </span>
          {% endif %}
        </div>
      </div>

      <!-- CORS Proxy -->
      <div class="col-md-6">
        <div class="service-card">
          <div class="service-name"><i class="fa-solid fa-shuffle me-2 text-purple"></i>CORS Proxy Server</div>
          <div class="service-detail mb-2">{{ "http://127.0.0.1:5173" }}</div>
          {% set p = health.cors_proxy %}
          {% if p.proxy == 'healthy' %}
            <span class="health-badge hb-healthy"><i class="fa fa-circle-check"></i>Proxy OK</span>
            &nbsp;
            {% if p.backend == 'healthy' %}
              <span class="health-badge hb-healthy"><i class="fa fa-circle-check"></i>Backend Reachable</span>
            {% elif p.backend == 'unreachable' %}
              <span class="health-badge hb-error"><i class="fa fa-circle-xmark"></i>Backend Unreachable</span>
            {% else %}
              <span class="health-badge hb-unknown">Backend: {{ p.backend }}</span>
            {% endif %}
          {% else %}
            <span class="health-badge hb-error"><i class="fa fa-circle-xmark"></i>
              {{ p.get('error', p.proxy) }}
            </span>
          {% endif %}
        </div>
      </div>

    </div>

    <!-- Auto-refresh info -->
    <div class="text-muted small mt-2">
      <i class="fa fa-rotate me-1"></i>
      Health panel auto-refreshes every 30 seconds.
      Last checked: <span id="health-ts">{{ health.checked_at }}</span>
    </div>
  </div><!-- /health -->

</div><!-- /main -->

<!-- ═══════════════ JAVASCRIPT ═══════════════ -->
<script>
/* ─── palette ─── */
const PALETTE = [
  '#58a6ff','#3fb950','#e3b341','#f85149','#bc8cff',
  '#79c0ff','#56d364','#ffa657','#ff7b72','#d2a8ff',
];

/* ─── Helpers ─── */
function getDoctorName(request) {
  // Support both old format (doctorName) and new format (doctorFirstName + doctorLastName)
  if (request.doctorFirstName || request.doctorLastName) {
    const firstName = request.doctorFirstName || '';
    const lastName = request.doctorLastName || '';
    return `${firstName} ${lastName}`.trim() || '—';
  }
  return request.doctorName || '—';
}

function toggleMobileMenu() {
  const sidebar = document.getElementById('sidebar');
  const overlay = document.getElementById('mobile-overlay');
  sidebar.classList.toggle('show');
  overlay.classList.toggle('show');
}

function closeMobileMenu() {
  const sidebar = document.getElementById('sidebar');
  const overlay = document.getElementById('mobile-overlay');
  sidebar.classList.remove('show');
  overlay.classList.remove('show');
}

function showSection(name, el) {
  document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
  document.querySelector('#section-' + name).classList.add('active');
  document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
  el.classList.add('active');
  // Close mobile menu when navigating
  if (window.innerWidth <= 768) {
    closeMobileMenu();
  }
  event.preventDefault();
}

function filterTable(tableId, query) {
  const rows = document.querySelectorAll('#' + tableId + ' tbody tr');
  const q = query.toLowerCase();
  rows.forEach(r => {
    r.style.display = r.textContent.toLowerCase().includes(q) ? '' : 'none';
  });
  
  // Also filter mobile cards for requests
  if (tableId === 'request-table') {
    const cards = document.querySelectorAll('[data-request-card]');
    cards.forEach(card => {
      card.style.display = card.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
  }
}

/* ─── Advanced Doctor Filters ─── */
function applyDoctorFilters() {
  const searchQuery = document.getElementById('doctor-search').value.toLowerCase();
  const categoryFilter = document.getElementById('filter-category').value;
  const cityFilter = document.getElementById('filter-city').value;
  
  // Filter desktop table
  const rows = document.querySelectorAll('#doctor-table tbody tr');
  let visibleCount = 0;
  
  rows.forEach(row => {
    const text = row.textContent.toLowerCase();
    const cells = row.cells;
    
    // Get category and city from table cells (index 2 and 3)
    const category = cells[2]?.textContent.trim() || '';
    const city = cells[3]?.textContent.trim() || '';
    
    const matchesSearch = text.includes(searchQuery);
    const matchesCategory = !categoryFilter || category === categoryFilter;
    const matchesCity = !cityFilter || city === cityFilter;
    
    const shouldShow = matchesSearch && matchesCategory && matchesCity;
    row.style.display = shouldShow ? '' : 'none';
    if (shouldShow) visibleCount++;
  });
  
  // Filter mobile cards
  const cards = document.querySelectorAll('[data-doctor-card]');
  let mobileVisibleCount = 0;
  
  cards.forEach(card => {
    const text = card.textContent.toLowerCase();
    const categoryBadge = card.querySelector('.badge');
    const category = categoryBadge ? categoryBadge.textContent.trim() : '';
    
    // Find city in card rows
    const cityRow = Array.from(card.querySelectorAll('.card-row')).find(row => 
      row.querySelector('.card-label')?.textContent.includes('City')
    );
    const city = cityRow ? cityRow.querySelector('.card-value')?.textContent.trim() : '';
    
    const matchesSearch = text.includes(searchQuery);
    const matchesCategory = !categoryFilter || category === categoryFilter;
    const matchesCity = !cityFilter || city === cityFilter;
    
    const shouldShow = matchesSearch && matchesCategory && matchesCity;
    card.style.display = shouldShow ? '' : 'none';
    if (shouldShow) mobileVisibleCount++;
  });
  
  // Update count badge (use table count if available, otherwise mobile count)
  const count = visibleCount > 0 ? visibleCount : mobileVisibleCount;
  const badge = document.getElementById('doctors-count');
  if (badge) badge.textContent = count;
}

function clearDoctorFilters() {
  document.getElementById('doctor-search').value = '';
  document.getElementById('filter-category').value = '';
  document.getElementById('filter-city').value = '';
  applyDoctorFilters();
  showToast('Filters cleared', 'info');
}

function setNow() {
  const now = new Date();
  const timeStr = now.toLocaleTimeString();
  const dateStr = now.toLocaleDateString();
  document.getElementById('last-updated').textContent =
    `Last updated: ${timeStr}`;
  document.getElementById('last-updated').title = `${dateStr} ${timeStr}`;
}

/* ─── Charts ─── */
const charts = {};
function makeBar(id, labels, data, label='Count') {
  const ctx = document.getElementById(id);
  if (!ctx) return;
  if (charts[id]) charts[id].destroy();
  charts[id] = new Chart(ctx, {
    type: 'bar',
    data: {
      labels,
      datasets: [{
        label,
        data,
        backgroundColor: labels.map((_,i) => PALETTE[i % PALETTE.length] + 'bb'),
        borderColor:      labels.map((_,i) => PALETTE[i % PALETTE.length]),
        borderWidth: 1,
        borderRadius: 5,
      }]
    },
    options: {
      plugins: { legend: { display: false } },
      scales: {
        x: { ticks: { color: '#8b949e' }, grid: { color: '#21262d' } },
        y: { ticks: { color: '#8b949e' }, grid: { color: '#21262d' }, beginAtZero: true }
      }
    }
  });
}

function makePie(id, labels, data) {
  const ctx = document.getElementById(id);
  if (!ctx) return;
  if (charts[id]) charts[id].destroy();
  charts[id] = new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels,
      datasets: [{
        data,
        backgroundColor: labels.map((_,i) => PALETTE[i % PALETTE.length] + 'cc'),
        borderColor: '#161b22',
        borderWidth: 2,
      }]
    },
    options: {
      plugins: {
        legend: { position: 'bottom', labels: { color: '#8b949e', boxWidth: 12, padding: 10 } }
      }
    }
  });
}

function makeLine(id, labels, data) {
  const ctx = document.getElementById(id);
  if (!ctx) return;
  if (charts[id]) charts[id].destroy();
  charts[id] = new Chart(ctx, {
    type: 'line',
    data: {
      labels,
      datasets: [{
        label: 'Requests',
        data,
        borderColor: '#58a6ff',
        backgroundColor: 'rgba(88,166,255,.1)',
        fill: true,
        tension: 0.4,
        pointBackgroundColor: '#58a6ff',
      }]
    },
    options: {
      plugins: { legend: { display: false } },
      scales: {
        x: { ticks: { color: '#8b949e' }, grid: { color: '#21262d' } },
        y: { ticks: { color: '#8b949e' }, grid: { color: '#21262d' }, beginAtZero: true }
      }
    }
  });
}

/* ─── Render charts from data ─── */
function renderCharts(data) {
  const kv = obj => [Object.keys(obj), Object.values(obj)];

  // Doctors by category
  let [lbl, vals] = kv(data.doctors_by_category || {});
  makeBar('chartDoctorCategory', lbl, vals);

  // Doctors by city
  [lbl, vals] = kv(data.doctors_by_city || {});
  makePie('chartDoctorCity', lbl, vals);

  // Requests by status
  [lbl, vals] = kv(data.requests_by_status || {});
  makePie('chartRequestStatus', lbl, vals);

  // Requests by category
  [lbl, vals] = kv(data.requests_by_category || {});
  makeBar('chartRequestCategory', lbl, vals);

  // Doctors by university
  [lbl, vals] = kv(data.doctors_by_university || {});
  makeBar('chartDoctorUniversity', lbl, vals);

  // Timeline
  [lbl, vals] = kv(data.requests_timeline || {});
  makeLine('chartTimeline', lbl, vals);

  // Stat cards
  document.getElementById('total-doctors').textContent    = data.totals.doctors;
  document.getElementById('total-requests').textContent   = data.totals.requests;
  document.getElementById('total-categories').textContent = data.totals.categories;
  document.getElementById('total-cities').textContent     = data.totals.cities;

  // Table counts
  const dc = document.getElementById('doctors-count');
  if (dc) dc.textContent = data.totals.doctors;
  const rc = document.getElementById('requests-count');
  if (rc) rc.textContent = data.totals.requests;
}

/* ─── Health strip ─── */
function healthColor(status) {
  const s = (status||'').toLowerCase();
  if (['healthy','ok'].includes(s)) return 'dot-green';
  if (['error','unhealthy','unreachable'].includes(s)) return 'dot-red';
  return 'dot-yellow';
}

/* ─── Doctor Management Functions ─── */

// Helper to extract doctor name
function getDoctorName(r) {
  if (r.doctorFirstName || r.doctorLastName) {
    return `${r.doctorFirstName || ''} ${r.doctorLastName || ''}`.trim();
  }
  return r.doctorName || '—';
}

// Helper to get health badge color
function healthColor(status) {
  switch(status) {
    case 'healthy':
    case 'ok': return 'dot-green';
    case 'error':
    case 'unhealthy':
    case 'unreachable': return 'dot-red';
    case 'error': return 'dot-red';
    default: return 'dot-grey';
  }
}

// Filter doctors table
function applyDoctorFilters() {
  const category = document.getElementById('filter-category')?.value?.toLowerCase() || '';
  const city = document.getElementById('filter-city')?.value?.toLowerCase() || '';
  const search = document.getElementById('doctor-search')?.value?.toLowerCase() || '';
  
  // Filter desktop table
  const rows = document.querySelectorAll('#doctor-tbody tr');
  rows.forEach(row => {
    if (row.textContent.includes('No doctors')) return;
    
    const doctorData = row.getAttribute('data-doctor');
    if (!doctorData) return;
    
    try {
      const doctor = JSON.parse(doctorData);
      const fullName = `${doctor.firstName || ''} ${doctor.lastName || ''}`.toLowerCase();
      const catMatch = !category || (doctor.categoryName || '').toLowerCase().includes(category);
      const cityMatch = !city || (doctor.cityName || '').toLowerCase().includes(city);
      const searchMatch = !search || fullName.includes(search) || 
                         (doctor.email || '').toLowerCase().includes(search) ||
                         (doctor.phoneNumber || '').toLowerCase().includes(search);
      
      row.style.display = (catMatch && cityMatch && searchMatch) ? '' : 'none';
    } catch(e) {
      console.error('Parse error:', e);
    }
  });
  
  // Filter mobile cards
  const cards = document.querySelectorAll('#doctor-cards [data-doctor-card]');
  cards.forEach(card => {
    const id = card.getAttribute('data-id');
    const name = card.querySelector('.card-value strong')?.textContent?.toLowerCase() || '';
    const catBadge = card.querySelector('.badge')?.textContent?.toLowerCase() || '';
    const cityText = card.querySelectorAll('.card-value')[2]?.textContent?.toLowerCase() || '';
    
    const catMatch = !category || catBadge.includes(category);
    const cityMatch = !city || cityText.includes(city);
    const searchMatch = !search || name.includes(search);
    
    card.style.display = (catMatch && cityMatch && searchMatch) ? '' : 'none';
  });
}

// Clear all doctor filters
function clearDoctorFilters() {
  document.getElementById('filter-category').value = '';
  document.getElementById('filter-city').value = '';
  document.getElementById('doctor-search').value = '';
  applyDoctorFilters();
  showToast('Filters cleared', 'info');
}

// Generic table filter
function filterTable(tableId, searchText) {
  const rows = document.querySelectorAll(`#${tableId} tbody tr`);
  const search = searchText.toLowerCase();
  let visibleCount = 0;
  
  rows.forEach(row => {
    if (row.textContent.toLowerCase().includes(search)) {
      row.style.display = '';
      visibleCount++;
    } else {
      row.style.display = 'none';
    }
  });
  
  // Show/hide "no results" message if needed
  if (visibleCount === 0 && rows.length > 0) {
    const tbody = document.querySelector(`#${tableId} tbody`);
    let emptyMsg = tbody.querySelector('.no-results-row');
    if (!emptyMsg) {
      emptyMsg = document.createElement('tr');
      emptyMsg.className = 'no-results-row';
      emptyMsg.innerHTML = `<td colspan="100%" class="text-center text-muted py-4">No results found</td>`;
      tbody.appendChild(emptyMsg);
    }
    emptyMsg.style.display = '';
  } else {
    const emptyMsg = document.querySelector(`#${tableId} .no-results-row`);
    if (emptyMsg) emptyMsg.style.display = 'none';
  }
}

// Set current time display
function setNow() {
  const el = document.getElementById('current-time');
  if (el) el.textContent = new Date().toLocaleString();
}

// Mobile menu toggle
function toggleMobileMenu() {
  const sidebar = document.querySelector('.sidebar');
  const overlay = document.getElementById('mobile-overlay');
  if (sidebar && overlay) {
    sidebar.classList.toggle('show');
    overlay.classList.toggle('show');
  }
}

function closeMobileMenu() {
  const sidebar = document.querySelector('.sidebar');
  const overlay = document.getElementById('mobile-overlay');
  if (sidebar && overlay) {
    sidebar.classList.remove('show');
    overlay.classList.remove('show');
  }
}

// Switch sections
function showSection(sectionId) {
  document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
  const section = document.getElementById(`section-${sectionId}`);
  if (section) section.classList.add('active');
  
  document.querySelectorAll('.nav-link').forEach(link => link.classList.remove('active'));
  const navLink = document.querySelector(`[data-section="${sectionId}"]`);
  if (navLink) navLink.classList.add('active');
  
  closeMobileMenu();
}

// Render charts from analytics data
function renderCharts(data) {
  // Update stat cards
  const stats = [
    { id: 'total-doctors', key: 'doctors', icon: 'fa-user-doctor', color: '#58a6ff', label: 'Doctors' },
    { id: 'total-requests', key: 'requests', icon: 'fa-file-medical', color: '#3fb950', label: 'Requests' },
    { id: 'total-cities', key: 'cities', icon: 'fa-location-dot', color: '#f85149', label: 'Cities' },
    { id: 'total-categories', key: 'categories', icon: 'fa-tags', color: '#d29922', label: 'Categories' },
  ];
  
  stats.forEach(stat => {
    const el = document.getElementById(stat.id);
    if (el) {
      const value = data.totals?.[stat.key] || 0;
      el.textContent = value;
    }
  });
  
  // Update doctor/request counts
  const dcBadge = document.getElementById('doctors-count');
  const rcBadge = document.getElementById('requests-count');
  if (dcBadge) dcBadge.textContent = data.totals?.doctors || 0;
  if (rcBadge) rcBadge.textContent = data.totals?.requests || 0;
}

function renderHealthStrip(h) {
  const services = [
    { name: 'Spring Boot', status: h.backend?.status  },
    { name: 'AI Chatbot',  status: h.ai_chatbot?.status === 'ok' ? 'healthy' : h.ai_chatbot?.status },
    { name: 'OTP System',  status: h.otp_system?.status },
    { name: 'CORS Proxy',  status: h.cors_proxy?.proxy === 'healthy' ? 'healthy' : h.cors_proxy?.proxy },
  ];
  const strip = document.getElementById('health-strip');
  if (!strip) return;
  strip.innerHTML = services.map(s => `
    <div class="d-flex align-items-center gap-2">
      <span class="dot-pulse ${healthColor(s.status)}"></span>
      <span style="font-size:.85rem;color:#c9d1d9">${s.name}</span>
      <span style="font-size:.75rem;color:#8b949e">${s.status||'unknown'}</span>
    </div>
  `).join('');
  const ts = document.getElementById('health-ts');
  if (ts) ts.textContent = h.checked_at || '—';
}

/* ─── Prefix (injected server-side, never guessable by crawlers) ─── */
const BASE = "{{ admin_prefix }}";

/* ─── Auto-refresh state ─── */
let autoRefreshEnabled = true;
let analyticsRefreshInterval = null;
let healthRefreshInterval = null;
let isRefreshing = false;

/* ─── AJAX refresh ─── */
async function loadAnalytics(silent = false) {
  if (isRefreshing && !silent) return; // Prevent concurrent refreshes
  
  if (!silent) {
    isRefreshing = true;
    showRefreshingIndicator();
  }
  
  try {
    const res = await fetch(BASE + '/api/analytics');
    if (!res.ok) {
      if (!silent) showToast('Failed to refresh analytics', 'error');
      return;
    }
    const data = await res.json();
    renderCharts(data);
    rebuildDoctorTable(data.doctors_list || []);
    rebuildRequestTable(data.requests_list || []);
    setNow();
    if (!silent) showToast('Dashboard refreshed successfully', 'success');
  } catch(e) { 
    console.warn('Analytics load failed', e);
    if (!silent) showToast('Network error during refresh', 'error');
  } finally {
    isRefreshing = false;
    hideRefreshingIndicator();
  }
}

async function loadHealth(silent = true) {
  try {
    const res = await fetch(BASE + '/api/health');
    if (!res.ok) return;
    const data = await res.json();
    renderHealthStrip(data);
    const ts = document.getElementById('health-ts');
    if (ts) ts.textContent = data.checked_at || '—';
  } catch(e) { console.warn('Health load failed', e); }
}

function refreshAll() { 
  const btn = document.querySelector('.refresh-btn');
  if (btn) btn.classList.add('refreshing');
  
  Promise.all([loadAnalytics(false), loadHealth(false)])
    .finally(() => {
      if (btn) btn.classList.remove('refreshing');
    });
}

function showRefreshingIndicator() {
  const indicator = document.getElementById('refreshing-indicator');
  if (indicator) indicator.classList.add('show');
}

function hideRefreshingIndicator() {
  const indicator = document.getElementById('refreshing-indicator');
  if (indicator) indicator.classList.remove('show');
}

function toggleAutoRefresh() {
  autoRefreshEnabled = !autoRefreshEnabled;
  const btn = document.getElementById('auto-refresh-toggle');
  const icon = document.getElementById('refresh-icon');
  const text = document.getElementById('refresh-text');
  
  if (autoRefreshEnabled) {
    btn.classList.add('active');
    icon.className = 'fa-solid fa-play';
    if (text) text.textContent = 'Auto';
    btn.title = 'Auto-refresh enabled (every 30s)';
    startAutoRefresh();
    showToast('Auto-refresh enabled', 'success');
  } else {
    btn.classList.remove('active');
    icon.className = 'fa-solid fa-pause';
    if (text) text.textContent = 'Pause';
    btn.title = 'Auto-refresh paused';
    stopAutoRefresh();
    showToast('Auto-refresh paused', 'info');
  }
}

function startAutoRefresh() {
  // Clear existing intervals
  stopAutoRefresh();
  
  // Analytics refresh every 30 seconds
  analyticsRefreshInterval = setInterval(() => {
    if (autoRefreshEnabled && !document.querySelector('.modal-overlay.show')) {
      loadAnalytics(true); // Silent refresh
    }
  }, 30000);
  
  // Health refresh every 20 seconds
  healthRefreshInterval = setInterval(() => {
    if (autoRefreshEnabled) {
      loadHealth(true);
    }
  }, 20000);
}

function stopAutoRefresh() {
  if (analyticsRefreshInterval) {
    clearInterval(analyticsRefreshInterval);
    analyticsRefreshInterval = null;
  }
  if (healthRefreshInterval) {
    clearInterval(healthRefreshInterval);
    healthRefreshInterval = null;
  }
}

/* ─── Dynamic table rebuild ─── */
function rebuildDoctorTable(doctors) {
  const tbody = document.getElementById('doctor-tbody');
  const cardsContainer = document.getElementById('doctor-cards');
  
  // Rebuild desktop table
  if (tbody) {
    if (!doctors.length) {
      tbody.innerHTML = '<tr><td colspan="8" class="text-center text-muted py-4">No doctors found</td></tr>';
    } else {
      tbody.innerHTML = doctors.map((d,i) => `
        <tr>
          <td>${i+1}</td>
          <td>${(d.firstName||'')+' '+(d.lastName||'')}</td>
          <td><span class="badge bg-info text-dark">${d.categoryName||'—'}</span></td>
          <td>${d.cityName||'—'}</td>
          <td>${d.universityName||'—'}</td>
          <td>${d.studyYear||'—'}</td>
          <td>${d.phoneNumber||'—'}</td>
          <td>${d.id
            ? `<div class="btn-group btn-group-sm">
                 <button class="btn btn-outline-primary" onclick="viewDoctor(${d.id})" title="View Details"><i class="fa fa-eye"></i></button>
                 <button class="btn btn-outline-danger" onclick="deleteDoctor(${d.id},this)" title="Delete"><i class="fa fa-trash"></i></button>
               </div>`
            : '<span class="text-muted">—</span>'}</td>
        </tr>
      `).join('');
    }
  }
  
  // Rebuild mobile cards
  if (cardsContainer) {
    if (!doctors.length) {
      cardsContainer.innerHTML = '<div class="text-center text-muted py-4">No doctors found</div>';
    } else {
      cardsContainer.innerHTML = doctors.map(d => `
        <div class="data-item-card" data-doctor-card data-id="${d.id||''}">
          <div class="card-row">
            <span class="card-label"><i class="fa fa-user me-1"></i>Name</span>
            <span class="card-value"><strong>${(d.firstName||'')+' '+(d.lastName||'')}</strong></span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-tag me-1"></i>Category</span>
            <span class="card-value"><span class="badge bg-info text-dark">${d.categoryName||'—'}</span></span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-location-dot me-1"></i>City</span>
            <span class="card-value">${d.cityName||'—'}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-university me-1"></i>University</span>
            <span class="card-value">${d.universityName||'—'}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-graduation-cap me-1"></i>Study Year</span>
            <span class="card-value">${d.studyYear||'—'}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-phone me-1"></i>Phone</span>
            <span class="card-value">${d.phoneNumber||'—'}</span>
          </div>
          ${d.id ? `
          <div class="d-flex gap-2 mt-3">
            <button class="btn btn-sm btn-outline-primary flex-fill" onclick="viewDoctor(${d.id})" title="View Details">
              <i class="fa fa-eye me-1"></i>View
            </button>
            <button class="btn btn-sm btn-outline-danger flex-fill" onclick="deleteDoctor(${d.id},this)" title="Delete">
              <i class="fa fa-trash me-1"></i>Delete
            </button>
          </div>
          ` : ''}
        </div>
      `).join('');
    }
  }
}

function rebuildRequestTable(reqs) {
  const tbody = document.querySelector('#request-table tbody');
  const cardsContainer = document.getElementById('request-cards');
  
  const statusBadge = s => {
    switch((s||'').toUpperCase()) {
      case 'PENDING':  return '<span class="badge badge-pending">⏳ Pending</span>';
      case 'APPROVED': return '<span class="badge badge-approved">✅ Approved</span>';
      case 'REJECTED': return '<span class="badge badge-rejected">❌ Rejected</span>';
      default:         return `<span class="badge badge-unknown">${s||'UNKNOWN'}</span>`;
    }
  };
  
  // Rebuild desktop table
  if (tbody) {
    if (!reqs.length) {
      tbody.innerHTML = '<tr><td colspan="9" class="text-center text-muted py-4">No requests found</td></tr>';
    } else {
      tbody.innerHTML = reqs.map((r,i) => `
        <tr>
          <td>${i+1}</td>
          <td>${r.id||'—'}</td>
          <td>${getDoctorName(r)}</td>
          <td>${r.doctorPhoneNumber||'—'}</td>
          <td>${r.doctorCityName||'—'}</td>
          <td>${r.categoryName||'—'}</td>
          <td>${statusBadge(r.status)}</td>
          <td>${r.dateTime||'—'}</td>
          <td class="text-muted" style="max-width:250px;white-space:normal">${r.description||'—'}</td>
        </tr>
      `).join('');
    }
  }
  
  // Rebuild mobile cards
  if (cardsContainer) {
    if (!reqs.length) {
      cardsContainer.innerHTML = '<div class="text-center text-muted py-4">No requests found</div>';
    } else {
      cardsContainer.innerHTML = reqs.map(r => `
        <div class="data-item-card" data-request-card>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-hashtag me-1"></i>ID</span>
            <span class="card-value"><strong>${r.id||'—'}</strong></span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-user-doctor me-1"></i>Doctor</span>
            <span class="card-value">${getDoctorName(r)}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-phone me-1"></i>Phone</span>
            <span class="card-value">${r.doctorPhoneNumber||'—'}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-location-dot me-1"></i>City</span>
            <span class="card-value">${r.doctorCityName||'—'}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-university me-1"></i>University</span>
            <span class="card-value">${r.doctorUniversityName||'—'}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-tag me-1"></i>Category</span>
            <span class="card-value">${r.categoryName||'—'}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-clock me-1"></i>Status</span>
            <span class="card-value">${statusBadge(r.status)}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-calendar me-1"></i>Date & Time</span>
            <span class="card-value">${r.dateTime||'—'}</span>
          </div>
          <div class="card-row">
            <span class="card-label"><i class="fa fa-file-text me-1"></i>Description</span>
            <span class="card-value text-muted" style="text-align: left; font-size: 0.8rem;">${r.description||'—'}</span>
          </div>
        </div>
      `).join('');
    }
  }
}

/* ─── Delete doctor ─── */
async function deleteDoctor(id, btn) {
  if (!confirm(`Delete doctor ID ${id}? This action cannot be undone.`)) return;
  
  const originalHTML = btn.innerHTML;
  btn.disabled = true;
  btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i>';
  
  try {
    const res = await fetch(`${BASE}/api/doctor/delete/${id}`, { method: 'POST' });
    if (!res.ok) {
      const errorText = await res.text();
      throw new Error(`HTTP ${res.status}: ${errorText}`);
    }
    const data = await res.json();
    if (data.success) {
      // Remove the row/card immediately
      const tableRow = btn.closest('tr');
      if (tableRow) tableRow.remove();
      
      const mobileCard = btn.closest('[data-doctor-card]');
      if (mobileCard) mobileCard.remove();
      
      // Update counts
      const dc = document.getElementById('total-doctors');
      if (dc) dc.textContent = parseInt(dc.textContent||0) - 1;
      
      const badge = document.getElementById('doctors-count');
      if (badge) badge.textContent = parseInt(badge.textContent||0) - 1;
      
      showToast(`Doctor ID ${id} deleted successfully`, 'success');
      
      // Trigger a silent refresh after 2 seconds to ensure data consistency
      setTimeout(() => loadAnalytics(true), 2000);
    } else {
      showToast('Delete failed: ' + data.message, 'error');
      btn.disabled = false;
      btn.innerHTML = originalHTML;
    }
  } catch(e) {
    showToast('Request error: ' + e.message, 'error');
    btn.disabled = false;
    btn.innerHTML = originalHTML;
  }
}

/* ─── Init ─── */
(function init() {
  // Initial chart render from server-side data
  const initialData = {{ analytics | tojson }};
  renderCharts(initialData);
  renderHealthStrip({{ health | tojson }});
  setNow();

  // Start auto-refresh intervals
  startAutoRefresh();
  
  // Load theme preference
  const savedTheme = localStorage.getItem('theme');
  if (savedTheme === 'light') {
    document.body.classList.add('light-mode');
  }
  
  // Handle window resize - close mobile menu when resizing to desktop
  let resizeTimer;
  window.addEventListener('resize', function() {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(function() {
      if (window.innerWidth > 768) {
        closeMobileMenu();
      }
    }, 250);
  });
  
  // Set initial counts
  const doctorCards = document.querySelectorAll('[data-doctor-card]');
  const requestCards = document.querySelectorAll('[data-request-card]');
  const dcBadge = document.getElementById('doctors-count');
  const rcBadge = document.getElementById('requests-count');
  
  if (dcBadge && !dcBadge.textContent) {
    dcBadge.textContent = doctorCards.length || initialData.totals.doctors;
  }
  if (rcBadge && !rcBadge.textContent) {
    rcBadge.textContent = requestCards.length || initialData.totals.requests;
  }
})();

/* ─── Export Functions ─── */
function exportDoctors() {
  window.location.href = `${BASE}/api/export/doctors`;
  showToast('Downloading doctors CSV...', 'info');
}

function exportRequests() {
  window.location.href = `${BASE}/api/export/requests`;
  showToast('Downloading requests CSV...', 'info');
}

/* ─── Doctor Details Modal ─── */
async function viewDoctor(id) {
  try {
    const res = await fetch(`${BASE}/api/doctor/${id}`);
    if (!res.ok) {
      throw new Error(`HTTP ${res.status}: ${res.statusText}`);
    }
    const data = await res.json();
    if (data.success && data.data) {
      showDoctorModal(data.data);
    } else {
      showToast('Failed to load doctor details: ' + (data.message || 'Unknown error'), 'error');
    }
  } catch(e) {
    console.error('View doctor error:', e);
    showToast('Error loading doctor: ' + e.message, 'error');
  }
}

function showDoctorModal(doctor) {
  const modal = document.getElementById('doctor-modal');
  const content = document.getElementById('doctor-modal-content');
  
  if (!modal || !content) {
    console.error('Modal elements not found');
    showToast('Modal error: elements not found', 'error');
    return;
  }
  
  content.innerHTML = `
    <div class="modal-row">
      <div class="modal-label">Name</div>
      <div class="modal-value">${doctor.firstName || ''} ${doctor.lastName || ''}</div>
    </div>
    <div class="modal-row">
      <div class="modal-label">Email</div>
      <div class="modal-value">${doctor.email || '—'}</div>
    </div>
    <div class="modal-row">
      <div class="modal-label">Phone</div>
      <div class="modal-value">${doctor.phoneNumber || '—'}</div>
    </div>
    <div class="modal-row">
      <div class="modal-label">Category</div>
      <div class="modal-value">${doctor.categoryName || '—'}</div>
    </div>
    <div class="modal-row">
      <div class="modal-label">City</div>
      <div class="modal-value">${doctor.cityName || '—'}</div>
    </div>
    <div class="modal-row">
      <div class="modal-label">University</div>
      <div class="modal-value">${doctor.universityName || '—'}</div>
    </div>
    <div class="modal-row">
      <div class="modal-label">Study Year</div>
      <div class="modal-value">${doctor.studyYear || '—'}</div>
    </div>
  `;
  
  modal.classList.add('show');
  
  // Pause auto-refresh while modal is open
  if (autoRefreshEnabled) {
    stopAutoRefresh();
    modal.dataset.resumeRefresh = 'true';
  }
}

function closeDoctorModal() {
  const modal = document.getElementById('doctor-modal');
  modal.classList.remove('show');
  
  // Resume auto-refresh if it was paused for the modal
  if (modal.dataset.resumeRefresh === 'true') {
    startAutoRefresh();
    delete modal.dataset.resumeRefresh;
  }
}

/* ─── Toast Notifications ─── */
let toastId = 0;
function showToast(message, type = 'info') {
  const container = document.getElementById('toast-container');
  if (!container) {
    console.error('Toast container not found');
    console.log(message); // Fallback to console
    return;
  }
  
  const id = `toast-${toastId++}`;
  
  const icons = {
    success: 'fa-circle-check',
    error: 'fa-circle-xmark',
    info: 'fa-circle-info'
  };
  
  const toast = document.createElement('div');
  toast.id = id;
  toast.className = `toast toast-${type}`;
  toast.innerHTML = `
    <i class="fa ${icons[type] || icons.info} toast-icon"></i>
    <div class="toast-message">${message}</div>
  `;
  
  container.appendChild(toast);
  
  setTimeout(() => {
    toast.classList.add('hiding');
    setTimeout(() => toast.remove(), 300);
  }, 4000);
}

/* ─── Theme Toggle ─── */
function toggleTheme() {
  document.body.classList.toggle('light-mode');
  const isLight = document.body.classList.contains('light-mode');
  localStorage.setItem('theme', isLight ? 'light' : 'dark');
  showToast(`Switched to ${isLight ? 'light' : 'dark'} mode`, 'success');
}
</script>

<!-- Refreshing Indicator -->
<div id="refreshing-indicator" class="refreshing-indicator">
  <div class="refresh-spinner"></div>
  <span style="font-size: 0.85rem; color: var(--accent);">Updating...</span>
</div>

<!-- Toast Container -->
<div id="toast-container" class="toast-container"></div>

<!-- Doctor Details Modal -->
<div id="doctor-modal" class="modal-overlay" onclick="if(event.target === this) closeDoctorModal()">
  <div class="modal-content">
    <div class="modal-header">
      <h5><i class="fa fa-user-doctor me-2"></i>Doctor Details</h5>
      <button class="modal-close" onclick="closeDoctorModal()">&times;</button>
    </div>
    <div class="modal-body" id="doctor-modal-content">
      <!-- Populated by JS -->
    </div>
  </div>
</div>

<!-- Theme Toggle -->
<div class="theme-toggle" onclick="toggleTheme()" title="Toggle Dark/Light Mode">
  <i class="fa fa-circle-half-stroke"></i>
</div>

</body>
</html>
"""


# ─────────────────────────────────────────────
#  ENTRY POINT
# ─────────────────────────────────────────────

if __name__ == "__main__":
    print(f"""
╔══════════════════════════════════════════════════════════╗
║       Teeth Management System — Admin Dashboard          ║
╠══════════════════════════════════════════════════════════╣
║  Login URL:  http://localhost:{DASHBOARD_PORT}{ADMIN_PREFIX}/login
║  Backend:    {BACKEND_URL:<44} ║
║  AI Chatbot: {AI_URL:<44} ║
║  OTP System: {OTP_URL:<44} ║
║  CORS Proxy: {PROXY_URL:<44} ║
║  NOTE: All other paths return 404 (crawler-safe)         ║
╚══════════════════════════════════════════════════════════╝
    """)
    app.run(host="0.0.0.0", port=DASHBOARD_PORT, debug=False)
