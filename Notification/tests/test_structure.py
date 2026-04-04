"""Basic test for notification service structure"""
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(__file__))

def test_imports():
    """Test that all modules can be imported"""
    try:
        # Test basic imports
        print("✓ Testing imports...")
        
        from models.database_models import NotificationQueue
        print("  ✓ Database models import successful")
        
        from services.firebase_service import FirebaseService
        print("  ✓ Firebase service import successful")
        
        from services.email_service import EmailService
        print("  ✓ Email service import successful")
        
        from services.notification_service import NotificationService
        print("  ✓ Notification service import successful")
        
        from services.queue_service import QueueService
        print("  ✓ Queue service import successful")
        
        from routes.notification_routes import router
        print("  ✓ Notification routes import successful")
        
        from utils.idempotency import generate_idempotency_key
        print("  ✓ Idempotency utilities import successful")
        
        print("\n✓ All imports successful!")
        return True
        
    except ImportError as e:
        print(f"\n✗ Import error: {e}")
        return False
    except Exception as e:
        print(f"\n✗ Unexpected error: {e}")
        return False

def test_key_generation():
    """Test idempotency key generation"""
    try:
        print("\n✓ Testing idempotency key generation...")
        from utils.idempotency import generate_idempotency_key, validate_idempotency
        
        key = generate_idempotency_key("test_data")
        print(f"  Generated key: {key[:16]}...")
        
        is_valid = validate_idempotency(key)
        print(f"  Key validation: {is_valid}")
        
        if is_valid:
            print("✓ Key generation test passed!")
            return True
        else:
            print("✗ Key validation failed!")
            return False
            
    except Exception as e:
        print(f"✗ Error in key generation test: {e}")
        return False

def main():
    """Run all tests"""
    print("=========================================")
    print("Notification Service Structure Tests")
    print("=========================================\n")
    
    results = []
    
    # Test imports
    results.append(("Imports", test_imports()))
    
    # Test key generation
    results.append(("Key Generation", test_key_generation()))
    
    # Summary
    print("\n=========================================")
    print("Test Summary")
    print("=========================================")
    for test_name, passed in results:
        status = "✓ PASSED" if passed else "✗ FAILED"
        print(f"{test_name}: {status}")
    
    all_passed = all(passed for _, passed in results)
    print(f"\nOverall: {'✓ ALL TESTS PASSED' if all_passed else '✗ SOME TESTS FAILED'}")
    
    return all_passed

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
