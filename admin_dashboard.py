"""
Admin Analytics Dashboard — Teeth Management System
=====================================================
A Flask web app that provides a rich analytics dashboard for the admin.

Features:
  - Admin login via the Spring Boot JWT auth endpoint
  - Live analytics: doctors, requests, categories, cities, appointments
  - Service health monitoring (same services tracked by the Discord bot)
  - Full doctor & request tables with delete action (admin privilege)
  - Auto-refreshing health panel every 30 seconds
  - Responsive UI (Bootstrap 5 dark theme + Chart.js + Font Awesome)

Configuration (env vars or edit the CONFIG block below):
  BACKEND_URL     Spring Boot base URL  (default: http://localhost:8080)
  AI_URL          AI chatbot base URL   (default: http://127.0.0.1:5010)
  OTP_URL         OTP service base URL  (default: http://127.0.0.1:8000)
  PROXY_URL       CORS proxy base URL   (default: http://127.0.0.1:5173)
  DASHBOARD_PORT  Port to run dashboard (default: 5500)
  SECRET_KEY      Flask session secret  (default: auto-generated)

Usage:
  pip install flask flask-cors requests
  python admin_dashboard.py
"""

import os
import json
import secrets
from datetime import datetime, timezone
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
DASHBOARD_PORT = int(os.getenv("DASHBOARD_PORT", "5500"))
SECRET_KEY     = os.getenv("SECRET_KEY",     secrets.token_hex(32))
REQUEST_TIMEOUT = 6  # seconds

app = Flask(__name__)
app.secret_key = SECRET_KEY
CORS(app)

# ─────────────────────────────────────────────
#  OBFUSCATED ROUTE PREFIX
#  All dashboard URLs are served under this prefix.
#  Anything outside it returns 404, making the admin
#  panel invisible to crawlers and path scanners.
#  Override via env:  ADMIN_PREFIX=/your-custom-path
# ─────────────────────────────────────────────
ADMIN_PREFIX = os.getenv("ADMIN_PREFIX", "/api/tms-mng-x7k2p9q3").rstrip("/")


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
        if not session.get("jwt_token"):
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
                session["jwt_token"]   = data.get("token") or data.get("accessToken") or list(data.values())[0]
                session["admin_email"] = email
                return redirect(url_for("dashboard"))
            else:
                error = f"Invalid credentials (HTTP {r.status_code})"
        except Exception as exc:
            error = f"Cannot reach backend: {exc}"
    return render_template_string(LOGIN_TEMPLATE, error=error)


@app.route(f"{ADMIN_PREFIX}/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))


@app.route(f"{ADMIN_PREFIX}/")
@login_required
def dashboard():
    token = session["jwt_token"]
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
    body { background: var(--bg-base); color: #c9d1d9; font-family: 'Segoe UI', system-ui, sans-serif; }

    /* ── Sidebar ── */
    .sidebar {
      position: fixed; top: 0; left: 0; bottom: 0; width: 240px;
      background: var(--bg-card); border-right: 1px solid var(--border);
      display: flex; flex-direction: column; z-index: 100;
      padding-top: 1rem;
    }
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

    /* ── Main ── */
    .main { margin-left: 240px; padding: 2rem; }
    .page-header {
      background: var(--bg-card); border: 1px solid var(--border);
      border-radius: 12px; padding: 1.2rem 1.5rem; margin-bottom: 2rem;
      display: flex; align-items: center; justify-content: space-between;
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
    }
    .data-card .card-head h6 { margin: 0; font-weight: 700; color: #f0f6fc; }
    table { margin: 0; }
    thead { background: var(--bg-card2); }
    th { font-size: .8rem; text-transform: uppercase; color: var(--text-muted); letter-spacing: .05em; }
    td, th { border-color: var(--border) !important; padding: .65rem 1rem !important; }
    tbody tr:hover { background: rgba(88,166,255,.05); }

    /* ── Misc ── */
    .section { display: none; }
    .section.active { display: block; }
    .refresh-btn { cursor: pointer; }
    .dot-pulse { display: inline-block; width: 8px; height: 8px; border-radius: 50%; }
    .dot-green { background: var(--green); }
    .dot-red   { background: var(--red); }
    .dot-yellow{ background: var(--yellow); }
    .dot-grey  { background: var(--text-muted); }
    #last-updated { font-size: .75rem; color: var(--text-muted); }
    .delete-btn { padding: .2rem .6rem; font-size: .78rem; }
    .badge-pending  { background: rgba(210,153,34,.2);  color: var(--orange); border: 1px solid rgba(210,153,34,.3); }
    .badge-approved { background: rgba(63,185,80,.2);   color: var(--green);  border: 1px solid rgba(63,185,80,.3); }
    .badge-rejected { background: rgba(248,81,73,.2);   color: var(--red);    border: 1px solid rgba(248,81,73,.3); }
    .badge-unknown  { background: rgba(139,148,158,.15); color: var(--text-muted); border: 1px solid var(--border); }

    @media(max-width:768px){
      .sidebar { display: none; }
      .main { margin-left: 0; padding: 1rem; }
    }
  </style>
</head>
<body>

<!-- ═══════════════ SIDEBAR ═══════════════ -->
<div class="sidebar">
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
    <a href="/logout" class="btn btn-sm btn-outline-danger w-100">
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
    <button class="btn btn-sm btn-outline-secondary refresh-btn" onclick="refreshAll()">
      <i class="fa-solid fa-rotate-right me-1"></i>Refresh
    </button>
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
        <h6><i class="fa-solid fa-user-doctor me-2 text-info"></i>All Registered Doctors
          <span class="badge bg-secondary ms-2" id="doctors-count"></span>
        </h6>
        <input type="text" id="doctor-search" class="form-control form-control-sm w-auto"
               placeholder="🔍 Search…" oninput="filterTable('doctor-table',this.value)">
      </div>
      <div class="table-responsive">
        <table class="table table-hover table-sm" id="doctor-table">
          <thead>
            <tr>
              <th>#</th><th>Name</th><th>Category</th><th>City</th>
              <th>University</th><th>Study Year</th><th>Phone</th><th>Action</th>
            </tr>
          </thead>
          <tbody id="doctor-tbody">
            {% for d in analytics.doctors_list %}
            <tr data-id="">
              <td>{{ loop.index }}</td>
              <td>{{ d.firstName or '' }} {{ d.lastName or '' }}</td>
              <td><span class="badge bg-info text-dark">{{ d.categoryName or '—' }}</span></td>
              <td>{{ d.cityName or '—' }}</td>
              <td>{{ d.universityName or '—' }}</td>
              <td>{{ d.studyYear or '—' }}</td>
              <td>{{ d.phoneNumber or '—' }}</td>
              <td>
                {% if d.get('id') %}
                <button class="btn btn-outline-danger delete-btn"
                        onclick="deleteDoctor({{ d.id }}, this)">
                  <i class="fa fa-trash"></i>
                </button>
                {% else %}<span class="text-muted">—</span>{% endif %}
              </td>
            </tr>
            {% else %}
            <tr><td colspan="8" class="text-center text-muted py-4">No doctors found</td></tr>
            {% endfor %}
          </tbody>
        </table>
      </div>
    </div>
  </div><!-- /doctors -->

  <!-- ── REQUESTS SECTION ── -->
  <div id="section-requests" class="section">
    <div class="data-card">
      <div class="card-head">
        <h6><i class="fa-solid fa-file-medical me-2 text-success"></i>All Service Requests
          <span class="badge bg-secondary ms-2" id="requests-count"></span>
        </h6>
        <input type="text" id="request-search" class="form-control form-control-sm w-auto"
               placeholder="🔍 Search…" oninput="filterTable('request-table',this.value)">
      </div>
      <div class="table-responsive">
        <table class="table table-hover table-sm" id="request-table">
          <thead>
            <tr>
              <th>#</th><th>ID</th><th>Doctor</th><th>Category</th>
              <th>Status</th><th>Date &amp; Time</th><th>Description</th>
            </tr>
          </thead>
          <tbody>
            {% for r in analytics.requests_list %}
            <tr>
              <td>{{ loop.index }}</td>
              <td>{{ r.id or '—' }}</td>
              <td>{{ r.doctorName or '—' }}</td>
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
            <tr><td colspan="7" class="text-center text-muted py-4">No requests found</td></tr>
            {% endfor %}
          </tbody>
        </table>
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
function showSection(name, el) {
  document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
  document.querySelector('#section-' + name).classList.add('active');
  document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
  el.classList.add('active');
  event.preventDefault();
}

function filterTable(tableId, query) {
  const rows = document.querySelectorAll('#' + tableId + ' tbody tr');
  const q = query.toLowerCase();
  rows.forEach(r => {
    r.style.display = r.textContent.toLowerCase().includes(q) ? '' : 'none';
  });
}

function setNow() {
  document.getElementById('last-updated').textContent =
    'Last updated: ' + new Date().toLocaleTimeString();
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

/* ─── AJAX refresh ─── */
async function loadAnalytics() {
  try {
    const res = await fetch(BASE + '/api/analytics');
    if (!res.ok) return;
    const data = await res.json();
    renderCharts(data);
    rebuildDoctorTable(data.doctors_list || []);
    rebuildRequestTable(data.requests_list || []);
    setNow();
  } catch(e) { console.warn('Analytics load failed', e); }
}

async function loadHealth() {
  try {
    const res = await fetch(BASE + '/api/health');
    if (!res.ok) return;
    const data = await res.json();
    renderHealthStrip(data);
    const ts = document.getElementById('health-ts');
    if (ts) ts.textContent = data.checked_at || '—';
  } catch(e) { console.warn('Health load failed', e); }
}

function refreshAll() { loadAnalytics(); loadHealth(); }

/* ─── Dynamic table rebuild ─── */
function rebuildDoctorTable(doctors) {
  const tbody = document.getElementById('doctor-tbody');
  if (!tbody) return;
  if (!doctors.length) {
    tbody.innerHTML = '<tr><td colspan="8" class="text-center text-muted py-4">No doctors found</td></tr>';
    return;
  }
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
        ? `<button class="btn btn-outline-danger delete-btn" onclick="deleteDoctor(${d.id},this)"><i class="fa fa-trash"></i></button>`
        : '<span class="text-muted">—</span>'}</td>
    </tr>
  `).join('');
}

function rebuildRequestTable(reqs) {
  const tbody = document.querySelector('#request-table tbody');
  if (!tbody) return;
  if (!reqs.length) {
    tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted py-4">No requests found</td></tr>';
    return;
  }
  const statusBadge = s => {
    switch((s||'').toUpperCase()) {
      case 'PENDING':  return '<span class="badge badge-pending">⏳ Pending</span>';
      case 'APPROVED': return '<span class="badge badge-approved">✅ Approved</span>';
      case 'REJECTED': return '<span class="badge badge-rejected">❌ Rejected</span>';
      default:         return `<span class="badge badge-unknown">${s||'UNKNOWN'}</span>`;
    }
  };
  tbody.innerHTML = reqs.map((r,i) => `
    <tr>
      <td>${i+1}</td>
      <td>${r.id||'—'}</td>
      <td>${r.doctorName||'—'}</td>
      <td>${r.categoryName||'—'}</td>
      <td>${statusBadge(r.status)}</td>
      <td>${r.dateTime||'—'}</td>
      <td class="text-muted" style="max-width:250px;white-space:normal">${r.description||'—'}</td>
    </tr>
  `).join('');
}

/* ─── Delete doctor ─── */
async function deleteDoctor(id, btn) {
  if (!confirm(`Delete doctor ID ${id}? This action cannot be undone.`)) return;
  btn.disabled = true;
  btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i>';
  try {
    const res = await fetch(`${BASE}/api/doctor/delete/${id}`, { method: 'POST' });
    const data = await res.json();
    if (data.success) {
      btn.closest('tr').remove();
      const dc = document.getElementById('total-doctors');
      if (dc) dc.textContent = parseInt(dc.textContent||0) - 1;
    } else {
      alert('Delete failed: ' + data.message);
      btn.disabled = false;
      btn.innerHTML = '<i class="fa fa-trash"></i>';
    }
  } catch(e) {
    alert('Request error: ' + e);
    btn.disabled = false;
    btn.innerHTML = '<i class="fa fa-trash"></i>';
  }
}

/* ─── Init ─── */
(function init() {
  // Initial chart render from server-side data
  const initialData = {{ analytics | tojson }};
  renderCharts(initialData);
  renderHealthStrip({{ health | tojson }});
  setNow();

  // Auto-refresh health every 30 s
  setInterval(loadHealth, 30000);
})();
</script>
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
