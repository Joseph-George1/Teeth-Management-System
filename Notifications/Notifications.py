"""Notifications.py - Module initialization file for the Notification Service.

This allows the Notifications package to be imported and used by other modules.
"""

__version__ = "1.0.0"
__author__ = "Thoutha Development Team"
__title__ = "Thoutha Notification Service"

# Export main components
try:
    from services import firebase_service, notification_service
    from routes import router
    
    __all__ = [
        "firebase_service",
        "notification_service",
        "router",
        "__version__",
        "__author__"
    ]
except ImportError:
    # If imports fail, that's okay - the service will initialize at startup
    pass
