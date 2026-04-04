"""Queue management service"""
import logging
import json
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from models.database_models import NotificationQueue, NotificationDeliveryAudit
from services.firebase_service import FirebaseService
from utils.idempotency import generate_idempotency_key
from typing import Optional

logger = logging.getLogger(__name__)

class QueueService:
    """Manage notification queue"""
    
    def __init__(self, db: Session):
        self.db = db
        self.firebase_service = FirebaseService()
    
    def enqueue(self, user_id: int, title: str, body: str, 
               idempotency_key: str, payload: dict) -> NotificationQueue:
        """Queue notification ensuring exactly-once delivery via idempotency"""
        try:
            queue_item = NotificationQueue(
                idempotency_key=idempotency_key,
                user_id=user_id,
                payload=json.dumps(payload),
                status="PENDING",
                retry_count=0
            )
            self.db.add(queue_item)
            self.db.commit()
            logger.info(f"Queued notification for user {user_id} (key: {idempotency_key[:20]}...)")
            return queue_item
            
        except IntegrityError:
            self.db.rollback()
            existing = self.db.query(NotificationQueue).filter(
                NotificationQueue.idempotency_key == idempotency_key
            ).first()
            logger.info(f"Duplicate request (idempotency) - returning existing entry")
            return existing
        except Exception as e:
            self.db.rollback()
            logger.error(f"Failed to queue notification: {e}")
            raise
    
    def process_queue(self):
        """Process pending notifications from queue"""
        try:
            pending = self.db.query(NotificationQueue).filter(
                NotificationQueue.status == "PENDING"
            ).all()
            
            for item in pending:
                # TODO: Get device tokens for user from database
                # For now, log process
                logger.info(f"Processing queue item {item.id}: {item.title[:30]}...")
                
                # Update status based on result
                item.updated_at = datetime.utcnow()
                self.db.commit()
                
        except Exception as e:
            logger.error(f"Error processing queue: {e}")
            self.db.rollback()
    
    def get_delivery_status(self, fcm_message_id: str) -> Optional[dict]:
        """Get delivery status"""
        try:
            audit = self.db.query(NotificationDeliveryAudit).filter(
                NotificationDeliveryAudit.fcm_message_id == fcm_message_id
            ).first()
            
            if not audit:
                return None
            
            return {
                "fcm_message_id": audit.fcm_message_id,
                "status": audit.delivery_status,
                "sent_at": audit.created_at,
                "error": audit.error_message
            }
        except Exception as e:
            logger.error(f"Error getting delivery status: {e}")
            return None
