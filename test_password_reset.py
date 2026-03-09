#!/usr/bin/env python3
"""
Test script for Password Reset Service
Tests connectivity and basic functionality
"""

import requests
import sys
import time

# Configuration
PASSWORD_RESET_URL = "http://localhost:7000"
OTP_SERVICE_URL = "http://localhost:8000"

# Colors for output
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'

def print_success(msg):
    print(f"{GREEN}✓ {msg}{RESET}")

def print_error(msg):
    print(f"{RED}✗ {msg}{RESET}")

def print_warning(msg):
    print(f"{YELLOW}⚠ {msg}{RESET}")

def print_info(msg):
    print(f"{BLUE}ℹ {msg}{RESET}")

def test_service_health(url, service_name):
    """Test if service is running and healthy"""
    try:
        response = requests.get(f"{url}/health", timeout=5)
        if response.status_code == 200:
            print_success(f"{service_name} is running")
            return True
        else:
            print_error(f"{service_name} returned status code {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print_error(f"{service_name} is not running or not accessible at {url}")
        return False
    except Exception as e:
        print_error(f"Error testing {service_name}: {str(e)}")
        return False

def test_password_reset_endpoints():
    """Test password reset service endpoints"""
    print_info("\nTesting Password Reset Service Endpoints...")
    
    # Test root endpoint
    try:
        response = requests.get(PASSWORD_RESET_URL, timeout=5)
        if response.status_code == 200:
            data = response.json()
            print_success(f"Root endpoint working: {data.get('service')}")
        else:
            print_error(f"Root endpoint returned {response.status_code}")
    except Exception as e:
        print_error(f"Root endpoint error: {str(e)}")
    
    # Test invalid request (no phone number)
    try:
        response = requests.post(
            f"{PASSWORD_RESET_URL}/api/password-reset/request",
            json={},
            timeout=5
        )
        if response.status_code == 400:
            print_success("Validation working (empty request rejected)")
        else:
            print_warning(f"Unexpected status for invalid request: {response.status_code}")
    except Exception as e:
        print_error(f"Validation test error: {str(e)}")
    
    # Test invalid phone format
    try:
        response = requests.post(
            f"{PASSWORD_RESET_URL}/api/password-reset/request",
            json={"phone_number": "1234567890"},  # Missing + prefix
            timeout=5
        )
        if response.status_code == 400:
            print_success("Phone validation working (invalid format rejected)")
        else:
            print_warning(f"Unexpected status for invalid phone: {response.status_code}")
    except Exception as e:
        print_error(f"Phone validation test error: {str(e)}")

def test_otp_service_endpoints():
    """Test OTP service endpoints"""
    print_info("\nTesting OTP Service Endpoints...")
    
    try:
        response = requests.get(OTP_SERVICE_URL, timeout=5)
        if response.status_code == 200:
            data = response.json()
            print_success(f"OTP service root endpoint: {data.get('api')}")
        else:
            print_warning(f"OTP root endpoint returned {response.status_code}")
    except Exception as e:
        print_error(f"OTP endpoint test error: {str(e)}")

def check_database_connection():
    """Check if database connection info is accessible via health endpoint"""
    print_info("\nChecking Database Connection...")
    
    try:
        response = requests.get(f"{PASSWORD_RESET_URL}/api/password-reset/health", timeout=5)
        if response.status_code == 200:
            data = response.json()
            deps = data.get('dependencies', {})
            
            if deps.get('database') == 'connected':
                print_success("Database connection: OK")
            else:
                print_error(f"Database connection: {deps.get('database', 'unknown')}")
            
            if deps.get('otp_service') == 'connected':
                print_success("OTP service connection: OK")
            else:
                print_warning(f"OTP service connection: {deps.get('otp_service', 'unknown')}")
        else:
            print_error(f"Health check returned {response.status_code}")
    except Exception as e:
        print_error(f"Health check error: {str(e)}")

def interactive_test():
    """Interactive test with real phone number"""
    print_info("\n" + "="*60)
    print_info("Interactive Test (Optional)")
    print_info("="*60)
    print_warning("This will send a real OTP to a phone number.")
    
    response = input("\nDo you want to test with a real phone number? (y/n): ")
    if response.lower() != 'y':
        print_info("Skipping interactive test.")
        return
    
    phone = input("Enter phone number (international format, e.g., +1234567890): ")
    if not phone.startswith('+'):
        print_error("Phone number must start with +")
        return
    
    # Step 1: Request OTP
    print_info(f"\nStep 1: Requesting OTP for {phone}...")
    try:
        response = requests.post(
            f"{PASSWORD_RESET_URL}/api/password-reset/request",
            json={"phone_number": phone},
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            print_success(f"OTP sent! Check WhatsApp. Expires in {data.get('expires_in_seconds')} seconds")
            print_info(f"Associated email: {data.get('user_email', 'N/A')}")
            
            # Step 2: Verify OTP
            otp = input("\nEnter the OTP code from WhatsApp: ")
            print_info("Step 2: Verifying OTP...")
            
            verify_response = requests.post(
                f"{PASSWORD_RESET_URL}/api/password-reset/verify-otp",
                json={"phone_number": phone, "otp": otp},
                timeout=10
            )
            
            if verify_response.status_code == 200:
                verify_data = verify_response.json()
                print_success("OTP verified successfully!")
                print_info(f"Session expires in {verify_data.get('session_expires_in_minutes')} minutes")
                
                # Step 3: Change password
                new_pass = input("\nEnter new password (min 8 chars): ")
                confirm_pass = input("Confirm new password: ")
                
                if new_pass != confirm_pass:
                    print_error("Passwords don't match!")
                    return
                
                print_info("Step 3: Changing password...")
                
                change_response = requests.post(
                    f"{PASSWORD_RESET_URL}/api/password-reset/change-password",
                    json={
                        "phone_number": phone,
                        "new_password": new_pass,
                        "confirm_password": confirm_pass
                    },
                    timeout=10
                )
                
                if change_response.status_code == 200:
                    print_success("Password changed successfully! ✓")
                    print_info("You can now login with the new password.")
                else:
                    error_data = change_response.json()
                    print_error(f"Password change failed: {error_data.get('message')}")
            else:
                error_data = verify_response.json()
                print_error(f"OTP verification failed: {error_data.get('message')}")
        else:
            error_data = response.json()
            print_error(f"OTP request failed: {error_data.get('message')}")
    
    except Exception as e:
        print_error(f"Test error: {str(e)}")

def main():
    """Main test function"""
    print(f"\n{BLUE}{'='*60}")
    print("Password Reset Service - Test Suite")
    print(f"{'='*60}{RESET}\n")
    
    # Test 1: Check if Password Reset Service is running
    print_info("Test 1: Password Reset Service Health")
    pwd_reset_ok = test_service_health(PASSWORD_RESET_URL, "Password Reset Service")
    
    # Test 2: Check if OTP Service is running
    print_info("\nTest 2: OTP Service Health")
    otp_ok = test_service_health(OTP_SERVICE_URL, "OTP Service")
    
    if not pwd_reset_ok:
        print_error("\n❌ Password Reset Service is not running!")
        print_info("Start it with: python forgetpassword.py")
        print_info("Or use: ./start_password_reset.sh")
        sys.exit(1)
    
    if not otp_ok:
        print_warning("\n⚠ OTP Service is not running!")
        print_info("Start it with: cd OTP && python OTP_W.py")
    
    # Test 3: Database and dependencies
    check_database_connection()
    
    # Test 4: API endpoints
    test_password_reset_endpoints()
    
    # Test 5: OTP service endpoints (if available)
    if otp_ok:
        test_otp_service_endpoints()
    
    # Summary
    print(f"\n{BLUE}{'='*60}")
    print("Test Summary")
    print(f"{'='*60}{RESET}")
    
    if pwd_reset_ok and otp_ok:
        print_success("All services are running!")
        print_info("\nYou can now use the password reset service.")
    elif pwd_reset_ok:
        print_warning("Password Reset Service is running, but OTP service is not.")
        print_info("Some features may not work without OTP service.")
    else:
        print_error("Critical services are not running.")
    
    # Interactive test
    interactive_test()
    
    print(f"\n{BLUE}{'='*60}{RESET}")
    print_info("Testing completed!")
    print(f"{BLUE}{'='*60}{RESET}\n")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n\n{YELLOW}Test interrupted by user{RESET}")
        sys.exit(0)
