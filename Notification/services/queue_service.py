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
    
    def process_queue(self, db: Session):
        """
        Process pending notifications from queue and send via FCM
        
        CRITICAL: This is called every 2 seconds by APScheduler
        Flow:
          1. Query NOTIFICATION_QUEUE where status='PENDING'
          2. For each pending item:
             a. Get FCM tokens for the user from PATIENT_DEVICE_TOKENS
             b. Call firebase_service.send_to_device() for EACH token
             c. Update status to SENT/FAILED based on result
        """
        try:
            pending = db.query(NotificationQueue).filter(
                NotificationQueue.status == "PENDING"
            ).all()
            
            if not pending:
                return
            
            logger.info(f"Processing {len(pending)} pending notifications...")
            
            # Import here to avoid circular dependency
            from models.database_models import PatientDeviceToken
            
            for item in pending:
                try:
                    payload = json.loads(item.payload)
                    
                    # Extract title and body from payload
                    title = payload.get("title", "Notification")
                    body = payload.get("body", "You have a new notification")
                    
                    logger.info(f"Processing notification {item.id} for user {item.user_id}: '{title}'")
                    
                    # ===== Check if user_id is valid =====
                    if not item.user_id or item.user_id <= 0:
                        logger.warning(f"Notification {item.id} has invalid user_id ({item.user_id}) - cannot send")
                        item.status = "FAILED"
                        item.retry_count += 1
                        item.updated_at = datetime.utcnow()
                        
                        audit = NotificationDeliveryAudit(
                            notification_queue_id=item.id,
                            fcm_message_id=None,
                            delivery_status="FAILED",
                            error_message="Invalid or missing user_id"
                        )
                        db.add(audit)
                        db.commit()
                        continue
                    
                    # ===== CRITICAL: Get all active FCM tokens for this user =====
                    device_tokens = db.query(PatientDeviceToken).filter(
                        PatientDeviceToken.user_id == item.user_id,
                        PatientDeviceToken.is_active == True
                    ).all()
                    
                    if not device_tokens:
                        logger.warning(f"No active device tokens for user {item.user_id} - notification {item.id} cannot be sent")
                        item.status = "FAILED"
                        item.retry_count += 1
                        item.updated_at = datetime.utcnow()
                        
                        audit = NotificationDeliveryAudit(
                            notification_queue_id=item.id,
                            fcm_message_id=None,
                            delivery_status="FAILED",
                            error_message="No active device tokens for user"
                        )
                        db.add(audit)
                        db.commit()
                        continue
                    
                    # ===== CRITICAL: Send to EACH device via FCM =====
                    success_count = 0
                    failure_count = 0
                    
                    for device_token in device_tokens:
                        try:
                            logger.info(f"Sending to user {item.user_id} on device {device_token.device_type}...")
                            
                            # Actually call FCM service to send notification
                            fcm_message_id = self.firebase_service.send_to_device(
                                fcm_token=device_token.fcm_token,
                                title=title,
                                body=body,
                                data=payload
                            )
                            
                            if fcm_message_id:
                                success_count += 1
                                logger.info(f"✓ FCM sent to user {item.user_id}: {device_token.device_type} | ID: {fcm_message_id}")
                                
                                # Log successful send
                                audit = NotificationDeliveryAudit(
                                    notification_queue_id=item.id,
                                    fcm_message_id=fcm_message_id,
                                    delivery_status="SENT",
                                    error_message=None
                                )
                                db.add(audit)
                                
                                # Update device token last_used_at
                                device_token.last_used_at = datetime.utcnow()
                            else:
                                failure_count += 1
                                logger.warning(f"✗ FCM failed for user {item.user_id} on {device_token.device_type}")
                                
                                audit = NotificationDeliveryAudit(
                                    notification_queue_id=item.id,
                                    fcm_message_id=None,
                                    delivery_status="FAILED",
                                    error_message=f"FCM send failed for device {device_token.device_type}"
                                )
                                db.add(audit)
                        
                        except Exception as e:
                            failure_count += 1
                            logger.error(f"Error sending to FCM for user {item.user_id}: {e}")
                            
                            audit = NotificationDeliveryAudit(
                                notification_queue_id=item.id,
                                fcm_message_id=None,
                                delivery_status="FAILED",
                                error_message=str(e)
                            )
                            db.add(audit)
                    
                    # ===== Update queue item status =====
                    if success_count > 0:
                        item.status = "SENT"
                        logger.info(f"Notification {item.id} SENT to {success_count} device(s), {failure_count} failed")
                    else:
                        item.status = "FAILED"
                        item.retry_count += 1
                        logger.error(f"Notification {item.id} FAILED on all {len(device_tokens)} device(s)")
                    
                    item.updated_at = datetime.utcnow()
                    db.commit()
                    
                except Exception as e:
                    item.status = "FAILED"
                    item.retry_count += 1
                    item.updated_at = datetime.utcnow()
                    
                    audit = NotificationDeliveryAudit(
                        notification_queue_id=item.id,
                        fcm_message_id=None,
                        delivery_status="FAILED",
                        error_message=str(e)
                    )
                    db.add(audit)
                    db.commit()
                    
                    logger.error(f"Failed to process notification {item.id}: {e}")
            
        except Exception as e:
            logger.error(f"Error processing queue: {e}")
            db.rollback()
    
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
