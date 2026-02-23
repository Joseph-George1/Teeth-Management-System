from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, validator
import httpx
import random
import string
from datetime import datetime, timedelta
from typing import Dict, Optional
import asyncio
from collections import defaultdict
import threading
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="OTP WhatsApp API", version="1.0.0")

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
WAHA_API_BASE_URL = "http://127.0.0.1:3000"
WAHA_API_KEY = ""  # Set your WAHA API key here if authentication is required
OTP_LENGTH = 6
OTP_EXPIRY_MINUTES = 5
MAX_ATTEMPTS = 3
RATE_LIMIT_SECONDS = 60  # Minimum time between OTP requests per phone number

# Thread-safe storage for OTPs and metadata
class OTPStore:
    def __init__(self):
        self._store: Dict[str, dict] = {}
        self._lock = threading.Lock()
        self._rate_limit: Dict[str, datetime] = {}
    
    def generate_otp(self) -> str:
        """Generate a random 6-digit OTP"""
        return ''.join(random.choices(string.digits, k=OTP_LENGTH))
    
    def set_otp(self, phone_number: str, otp: str) -> None:
        """Store OTP with metadata"""
        with self._lock:
            self._store[phone_number] = {
                'otp': otp,
                'created_at': datetime.now(),
                'expires_at': datetime.now() + timedelta(minutes=OTP_EXPIRY_MINUTES),
                'attempts': 0,
                'verified': False
            }
            logger.info(f"OTP stored for {phone_number}")
    
    def get_otp_data(self, phone_number: str) -> Optional[dict]:
        """Retrieve OTP data for a phone number"""
        with self._lock:
            return self._store.get(phone_number)
    
    def increment_attempts(self, phone_number: str) -> int:
        """Increment verification attempts and return current count"""
        with self._lock:
            if phone_number in self._store:
                self._store[phone_number]['attempts'] += 1
                return self._store[phone_number]['attempts']
            return 0
    
    def mark_verified(self, phone_number: str) -> None:
        """Mark OTP as verified"""
        with self._lock:
            if phone_number in self._store:
                self._store[phone_number]['verified'] = True
                logger.info(f"OTP verified for {phone_number}")
    
    def delete_otp(self, phone_number: str) -> None:
        """Remove OTP data"""
        with self._lock:
            if phone_number in self._store:
                del self._store[phone_number]
                logger.info(f"OTP deleted for {phone_number}")
    
    def can_request_otp(self, phone_number: str) -> tuple[bool, Optional[int]]:
        """Check if phone number can request a new OTP (rate limiting)"""
        with self._lock:
            if phone_number in self._rate_limit:
                time_passed = (datetime.now() - self._rate_limit[phone_number]).total_seconds()
                if time_passed < RATE_LIMIT_SECONDS:
                    remaining = int(RATE_LIMIT_SECONDS - time_passed)
                    return False, remaining
            return True, None
    
    def update_rate_limit(self, phone_number: str) -> None:
        """Update rate limit timestamp"""
        with self._lock:
            self._rate_limit[phone_number] = datetime.now()
    
    def cleanup_expired(self) -> int:
        """Remove expired OTPs and return count of removed items"""
        with self._lock:
            now = datetime.now()
            expired_phones = [
                phone for phone, data in self._store.items()
                if data['expires_at'] < now
            ]
            for phone in expired_phones:
                del self._store[phone]
                logger.info(f"Cleaned up expired OTP for {phone}")
            
            # Also cleanup old rate limit entries (older than 1 hour)
            old_rate_limits = [
                phone for phone, timestamp in self._rate_limit.items()
                if (now - timestamp).total_seconds() > 3600
            ]
            for phone in old_rate_limits:
                del self._rate_limit[phone]
            
            return len(expired_phones)

# Initialize OTP store
otp_store = OTPStore()

# Pydantic models
class PhoneNumber(BaseModel):
    phone_number: str = Field(..., description="Phone number in international format (e.g., +1234567890)")
    
    @validator('phone_number')
    def validate_phone(cls, v):
        # Remove spaces and dashes
        v = v.replace(' ', '').replace('-', '')
        # Must start with + and contain only digits after that
        if not v.startswith('+'):
            raise ValueError('Phone number must start with +')
        if not v[1:].isdigit():
            raise ValueError('Phone number must contain only digits after +')
        if len(v) < 10 or len(v) > 15:
            raise ValueError('Phone number must be between 10 and 15 digits')
        return v

class OTPRequest(PhoneNumber):
    pass

class OTPVerification(PhoneNumber):
    otp: str = Field(..., description="6-digit OTP code", min_length=6, max_length=6)
    
    @validator('otp')
    def validate_otp(cls, v):
        if not v.isdigit():
            raise ValueError('OTP must contain only digits')
        return v

class OTPResponse(BaseModel):
    success: bool
    message: str
    phone_number: str
    expires_in_seconds: Optional[int] = None

class VerificationResponse(BaseModel):
    success: bool
    message: str
    phone_number: str
    verified: bool

# Background task for periodic cleanup
async def periodic_cleanup():
    """Periodically clean up expired OTPs"""
    while True:
        await asyncio.sleep(60)  # Run every minute
        count = otp_store.cleanup_expired()
        if count > 0:
            logger.info(f"Periodic cleanup: removed {count} expired OTPs")

@app.on_event("startup")
async def startup_event():
    """Start background tasks on app startup"""
    asyncio.create_task(periodic_cleanup())
    logger.info("OTP API started successfully")

# API Endpoints
@app.post("/api/otp/send", response_model=OTPResponse)
async def send_otp(request: OTPRequest, background_tasks: BackgroundTasks):
    """
    Send OTP to a phone number via WhatsApp
    """
    phone_number = request.phone_number
    
    # Check rate limiting
    can_request, wait_time = otp_store.can_request_otp(phone_number)
    if not can_request:
        raise HTTPException(
            status_code=429,
            detail=f"Too many requests. Please wait {wait_time} seconds before requesting a new OTP."
        )
    
    # Generate OTP
    otp = otp_store.generate_otp()
    
    # Send OTP via WAHA API
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            # WAHA API endpoint for sending messages
            waha_url = f"{WAHA_API_BASE_URL}/api/sendText"
            
            payload = {
                "chatId": f"{phone_number.replace('+', '')}@c.us",  # WhatsApp format
                "text": f"Your OTP verification code is: *{otp}*\n\nThis code will expire in {OTP_EXPIRY_MINUTES} minutes.\n\nIf you didn't request this code, please ignore this message.",
                "session": "default"  # Adjust based on your WAHA session name
            }
            
            # Prepare headers with API key if provided
            headers = {"Content-Type": "application/json"}
            if WAHA_API_KEY:
                headers["X-Api-Key"] = WAHA_API_KEY
            
            logger.info(f"Sending OTP to WAHA: {waha_url}")
            logger.info(f"Payload: chatId={payload['chatId']}, session={payload['session']}")
            logger.info(f"Using API key: {'Yes' if WAHA_API_KEY else 'No'}")
            
            response = await client.post(waha_url, json=payload, headers=headers)
            
            logger.info(f"WAHA API response status: {response.status_code}")
            logger.info(f"WAHA API response body: {response.text}")
            
            if response.status_code != 200 and response.status_code != 201:
                logger.error(f"WAHA API error: {response.status_code} - {response.text}")
                raise HTTPException(
                    status_code=502,
                    detail=f"Failed to send OTP via WhatsApp. WAHA returned: {response.status_code}"
                )
            
            logger.info(f"OTP sent successfully to {phone_number}")
    
    except HTTPException:
        raise
    except httpx.ConnectError as e:
        logger.error(f"Cannot connect to WAHA API at {WAHA_API_BASE_URL}: {str(e)}")
        raise HTTPException(
            status_code=503,
            detail=f"WhatsApp service is currently unavailable at {WAHA_API_BASE_URL}"
        )
    except httpx.TimeoutException as e:
        logger.error(f"WAHA API timeout: {str(e)}")
        raise HTTPException(
            status_code=504,
            detail="Request timeout. Please try again."
        )
    except Exception as e:
        logger.error(f"Unexpected error type: {type(e).__name__}")
        logger.error(f"Unexpected error details: {str(e)}")
        import traceback
        logger.error(f"Traceback: {traceback.format_exc()}")
        raise HTTPException(
            status_code=500,
            detail=f"An unexpected error occurred: {type(e).__name__} - {str(e)}"
        )
    
    # Store OTP
    otp_store.set_otp(phone_number, otp)
    otp_store.update_rate_limit(phone_number)
    
    # Schedule cleanup in background
    background_tasks.add_task(asyncio.sleep, OTP_EXPIRY_MINUTES * 60)
    
    return OTPResponse(
        success=True,
        message="OTP sent successfully via WhatsApp",
        phone_number=phone_number,
        expires_in_seconds=OTP_EXPIRY_MINUTES * 60
    )

@app.post("/api/otp/verify", response_model=VerificationResponse)
async def verify_otp(request: OTPVerification):
    """
    Verify OTP for a phone number
    """
    phone_number = request.phone_number
    provided_otp = request.otp
    
    # Get OTP data
    otp_data = otp_store.get_otp_data(phone_number)
    
    if not otp_data:
        raise HTTPException(
            status_code=404,
            detail="No OTP found for this phone number. Please request a new OTP."
        )
    
    # Check if already verified
    if otp_data['verified']:
        raise HTTPException(
            status_code=400,
            detail="OTP already verified. Please request a new OTP if needed."
        )
    
    # Check expiration
    if datetime.now() > otp_data['expires_at']:
        otp_store.delete_otp(phone_number)
        raise HTTPException(
            status_code=410,
            detail="OTP has expired. Please request a new OTP."
        )
    
    # Check attempts
    if otp_data['attempts'] >= MAX_ATTEMPTS:
        otp_store.delete_otp(phone_number)
        raise HTTPException(
            status_code=429,
            detail="Maximum verification attempts exceeded. Please request a new OTP."
        )
    
    # Verify OTP
    if otp_data['otp'] == provided_otp:
        otp_store.mark_verified(phone_number)
        logger.info(f"OTP verification successful for {phone_number}")
        # Delete OTP and phone number after successful verification
        otp_store.delete_otp(phone_number)
        return VerificationResponse(
            success=True,
            message="OTP verified successfully",
            phone_number=phone_number,
            verified=True
        )
    else:
        attempts = otp_store.increment_attempts(phone_number)
        remaining_attempts = MAX_ATTEMPTS - attempts
        
        logger.warning(f"Invalid OTP attempt for {phone_number}. Attempts: {attempts}/{MAX_ATTEMPTS}")
        
        if remaining_attempts > 0:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid OTP. {remaining_attempts} attempts remaining."
            )
        else:
            otp_store.delete_otp(phone_number)
            raise HTTPException(
                status_code=429,
                detail="Maximum verification attempts exceeded. Please request a new OTP."
            )

@app.get("/api/otp/status/{phone_number}")
async def check_otp_status(phone_number: str):
    """
    Check OTP status for a phone number
    """
    otp_data = otp_store.get_otp_data(phone_number)
    
    if not otp_data:
        return {
            "exists": False,
            "message": "No active OTP for this phone number"
        }
    
    is_expired = datetime.now() > otp_data['expires_at']
    
    if is_expired:
        otp_store.delete_otp(phone_number)
        return {
            "exists": False,
            "message": "OTP has expired"
        }
    
    time_remaining = int((otp_data['expires_at'] - datetime.now()).total_seconds())
    
    return {
        "exists": True,
        "verified": otp_data['verified'],
        "attempts": otp_data['attempts'],
        "max_attempts": MAX_ATTEMPTS,
        "time_remaining_seconds": time_remaining,
        "created_at": otp_data['created_at'].isoformat()
    }

@app.delete("/api/otp/{phone_number}")
async def delete_otp(phone_number: str):
    """
    Delete OTP for a phone number (admin/cleanup endpoint)
    """
    otp_data = otp_store.get_otp_data(phone_number)
    
    if not otp_data:
        raise HTTPException(
            status_code=404,
            detail="No OTP found for this phone number"
        )
    
    otp_store.delete_otp(phone_number)
    
    return {
        "success": True,
        "message": "OTP deleted successfully",
        "phone_number": phone_number
    }

@app.get("/")
async def root():
    """
    Root endpoint with API information
    """
    return {
        "api": "OTP WhatsApp API",
        "version": "1.0.0",
        "endpoints": {
            "send_otp": "POST /api/otp/send",
            "verify_otp": "POST /api/otp/verify",
            "check_status": "GET /api/otp/status/{phone_number}",
            "delete_otp": "DELETE /api/otp/{phone_number}"
        },
        "status": "running"
    }

@app.get("/health")
async def health_check():
    """
    Health check endpoint
    """
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat()
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
