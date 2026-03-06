# CORS Proxy Server

This Python script acts as an intermediate layer between the frontend and backend, handling CORS (Cross-Origin Resource Sharing) issues.

## Features

- ✅ Handles CORS for all endpoints
- ✅ Forwards all requests to the Spring Boot backend
- ✅ Maintains the same endpoint names
- ✅ Passes all data (headers, body, query parameters)
- ✅ Supports all HTTP methods (GET, POST, PUT, DELETE)
- ✅ Health check endpoint
- ✅ Error handling for connection issues

## Installation

1. Install the required dependencies:
```bash
pip install -r requirements.txt
```

Or install individually:
```bash
pip install flask flask-cors requests
```

## Configuration

The proxy server is configured to run on:
- **Proxy Server Port**: `5000`
- **Backend URL**: `http://localhost:8080` (default Spring Boot port)

To change the backend URL, edit the `BACKEND_URL` variable in `proxy_server.py`:
```python
BACKEND_URL = "http://localhost:8080"
```

## Usage

1. **Start the Spring Boot backend** (make sure it's running on port 8080)

2. **Start the proxy server**:
```bash
python proxy_server.py
```

3. **Update your frontend** to use the proxy server URL instead of direct backend calls:
   - Change from: `http://localhost:8080/api/...`
   - Change to: `http://localhost:5000/api/...`

## Endpoints

The proxy server forwards all endpoints from your backend:

### Authentication
- `POST /api/auth/login/doctor`
- `POST /api/auth/login/admin`
- `POST /api/auth/signup`

### Categories
- `GET /api/category/getCategories`

### Cities
- `GET /api/cities/getAllCities`

### Doctors
- `GET /api/doctor/getDoctors`
- `GET /api/doctor/getDoctorsByCity`
- `GET /api/doctor/getDoctorsByCategory`
- `GET /api/doctor/getDoctorById`
- `PUT /api/doctor/updateDoctor`
- `DELETE /api/doctor/deleteByDoctorAdmin`
- `DELETE /api/doctor/deleteDoctor`

### Requests
- `GET /api/request/getAllRequests`
- `GET /api/request/getRequestById/{id}`
- `POST /api/request/createRequest`
- `DELETE /api/request/deleteRequest`

### Universities
- All university endpoints are also proxied

### Special Endpoints
- `GET /` - Server information
- `GET /health` - Health check for both proxy and backend

## Example Usage

### Frontend JavaScript/React
```javascript
// Before (direct backend call - CORS issues)
fetch('http://localhost:8080/api/doctor/getDoctors')

// After (through proxy - no CORS issues)
fetch('http://localhost:5000/api/doctor/getDoctors')
```

### With Authentication Headers
```javascript
fetch('http://localhost:5000/api/doctor/getDoctors', {
  headers: {
    'Authorization': 'Bearer your-token-here',
    'Content-Type': 'application/json'
  }
})
```

### POST Request
```javascript
fetch('http://localhost:5000/api/auth/signup', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    username: 'user',
    password: 'pass'
  })
})
```

## Testing

Test the proxy server:
```bash
# Check server status
curl http://localhost:5000/

# Check health
curl http://localhost:5000/health

# Test an API endpoint
curl http://localhost:5000/api/category/getCategories
```

## Troubleshooting

### Backend Connection Error
If you see "Backend server is not available":
1. Ensure the Spring Boot backend is running
2. Check the backend is on port 8080
3. Verify the `BACKEND_URL` in `proxy_server.py`

### CORS Still Not Working
1. Clear your browser cache
2. Check browser console for specific CORS errors
3. Ensure you're calling the proxy (port 5000), not the backend directly

### Port Already in Use
If port 5000 is already in use, change the port in `proxy_server.py`:
```python
app.run(host='0.0.0.0', port=5001, debug=True)
```

## Production Deployment

For production, consider:
1. Disabling debug mode: `debug=False`
2. Using a production WSGI server like Gunicorn:
   ```bash
   pip install gunicorn
   gunicorn -w 4 -b 0.0.0.0:5000 proxy_server:app
   ```
3. Restricting CORS origins to specific domains instead of "*"
4. Adding authentication/rate limiting if needed
