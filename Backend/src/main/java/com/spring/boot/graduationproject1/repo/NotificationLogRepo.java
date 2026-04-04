package com.spring.boot.graduationproject1.repo;

import com.spring.boot.graduationproject1.model.NotificationLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Repository for NotificationLog entity
 * Handles database operations for notification tracking and audit logs
 */
public interface NotificationLogRepo extends JpaRepository<NotificationLog, Long> {
    
    /**
     * Find all notifications for a user
     */
    List<NotificationLog> findByRecipientUserIdAndRecipientUserTypeOrderByCreatedAtDesc(
        Long userId,
        NotificationLog.DeliveryStatus userType
    );
    
    /**
     * Find unread notifications for a user
     */
    List<NotificationLog> findByRecipientUserIdAndRecipientUserTypeAndIsReadFalseOrderByCreatedAtDesc(
        Long userId,
        NotificationLog.DeliveryStatus userType
    );
    
    /**
     * Find notifications by type for a user
     */
    List<NotificationLog> findByRecipientUserIdAndNotificationTypeOrderByCreatedAtDesc(
        Long userId,
        NotificationLog.NotificationType notificationType
    );
    
    /**
     * Find notifications related to specific entity
     */
    List<NotificationLog> findByRelatedEntityIdAndRelatedEntityType(
        Long entityId,
        String entityType
    );
    
    /**
     * Find notifications by delivery status
     */
    List<NotificationLog> findByDeliveryStatus(NotificationLog.DeliveryStatus status);
    
    /**
     * Find notifications sent within date range
     */
    List<NotificationLog> findBySentAtBetween(
        LocalDateTime startDate,
        LocalDateTime endDate
    );
    
    /**
     * Count unread notifications for user
     */
    Long countByRecipientUserIdAndRecipientUserTypeAndIsReadFalse(
        Long userId,
        NotificationLog.DeliveryStatus userType
    );
    
    /**
     * Count notifications by type and delivery status
     */
    Long countByNotificationTypeAndDeliveryStatus(
        NotificationLog.NotificationType type,
        NotificationLog.DeliveryStatus status
    );
    
    /**
     * Find failed notifications for retry
     */
    List<NotificationLog> findByDeliveryStatusAndSentAtBefore(
        NotificationLog.DeliveryStatus status,
        LocalDateTime cutoffTime
    );
}
