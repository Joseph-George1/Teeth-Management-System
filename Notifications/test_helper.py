"""
Development and Testing Helper Script
Provides utilities for testing the notification service
"""

import requests
import json
import sys

# Configuration
BASE_URL = "http://localhost:9000"
API_KEY = "thoutha-notification-service-key-2024"

class NotificationServiceTester:
    """Test utility for Notification Service"""
    
    def __init__(self, base_url=BASE_URL, api_key=API_KEY):
        self.base_url = base_url
        self.api_key = api_key
        self.session = requests.Session()
        self.session.headers.update({
            "X-API-Key": api_key,
            "Content-Type": "application/json"
        })
    
    def test_health(self):
        """Test health endpoint"""
        print("\n📋 Testing Health Endpoint...")
        try:
            response = self.session.get(f"{self.base_url}/api/notify/health")
            if response.status_code == 200:
                print("✓ Health check passed")
                print(json.dumps(response.json(), indent=2))
            else:
                print(f"✗ Health check failed: {response.status_code}")
        except Exception as e:
            print(f"✗ Error: {str(e)}")
    
    def test_send_notification(self, token: str, title: str = "Test", body: str = "Test message"):
        """Test send single notification"""
        print(f"\n📨 Testing Send Notification...")
        payload = {
            "token": token,
            "title": title,
            "body": body,
            "data": {"test": "true"}
        }
        try:
            response = self.session.post(
                f"{self.base_url}/api/notify/send",
                json=payload
            )
            print(f"Status: {response.status_code}")
            print(json.dumps(response.json(), indent=2))
        except Exception as e:
            print(f"✗ Error: {str(e)}")
    
    def test_multicast(self, tokens: list, title: str = "Multicast Test", body: str = "Testing multicast"):
        """Test multicast notification"""
        print(f"\n📨 Testing Multicast Notification...")
        payload = {
            "tokens": tokens,
            "title": title,
            "body": body,
            "data": {"type": "multicast"}
        }
        try:
            response = self.session.post(
                f"{self.base_url}/api/notify/send-multicast",
                json=payload
            )
            print(f"Status: {response.status_code}")
            print(json.dumps(response.json(), indent=2))
        except Exception as e:
            print(f"✗ Error: {str(e)}")
    
    def test_statistics(self):
        """Get service statistics"""
        print("\n📊 Fetching Statistics...")
        try:
            response = self.session.get(f"{self.base_url}/api/notify/statistics")
            if response.status_code == 200:
                print("✓ Statistics retrieved")
                print(json.dumps(response.json(), indent=2))
            else:
                print(f"✗ Failed: {response.status_code}")
        except Exception as e:
            print(f"✗ Error: {str(e)}")

def main():
    """Run tests"""
    print("=" * 60)
    print("Thoutha Notification Service - Test Suite")
    print("=" * 60)
    
    tester = NotificationServiceTester()
    
    # Test health
    tester.test_health()
    
    # Test statistics
    tester.test_statistics()
    
    print("\n" + "=" * 60)
    print("Tests completed")
    print("=" * 60)
    print("\nNote: To test actual notifications, provide valid Firebase device tokens")

if __name__ == "__main__":
    main()
