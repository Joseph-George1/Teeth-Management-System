package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.NotificationLogDto;
import com.spring.boot.graduationproject1.model.NotificationLog;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Interface for Notification Log Service
 * Tracks notification sending and delivery
 */
public interface INotificationLogService {
    
    /**
     * Create a log entry for a sent notification
     * @param recipientUserId ID of user receiving notification
     * @param recipientUserType Type of recipient (PATIENT, DOCTOR)
     * @param title Notification title
     * @param body Notification body
     * @param notificationType Type of notification
     * @param relatedEntityId Optional related entity ID (e.g., Appointment)
     * @param relatedEntityType Optional related entity type
     * @return Created NotificationLogDto
     */
    NotificationLogDto logNotification(
        Long recipientUserId,
        String recipientUserType,
        String title,
        String body,
        String notificationType,
        Long relatedEntityId,
        String relatedEntityType
    );
    
    /**
     * Update FCM message ID after successful send
     * @param notificationId Notification log ID
     * @param fcmMessageId FCM message ID from Firebase
     */
    void updateFCMMessageId(Long notificationId, String fcmMessageId);
    
    /**
     * Mark notification as delivered
     * @param fcmMessageId FCM message ID
     */
    void markAsDelivered(String fcmMessageId);
    
    /**
     * Mark notification as read by user
     * @param notificationId Notification log ID
     */
    void markAsRead(Long notificationId);
    
    /**
     * Get all notifications for a user
     * @param userId User ID
     * @param userType Type of user
     * @return List of NotificationLogDtos
     */
    List<NotificationLogDto> getUserNotifications(Long userId, String userType);
    
    /**
     * Get unread notifications for a user
     * @param userId User ID
     * @param userType Type of user
     * @return List of unread NotificationLogDtos
     */
    List<NotificationLogDto> getUnreadNotifications(Long userId, String userType);
    
    /**
     * Count unread notifications for a user
     * @param userId User ID
     * @param userType Type of user
     * @return Number of unread notifications
     */
    Long countUnreadNotifications(Long userId, String userType);
    
    /**
     * Get notifications by type
     * @param userId User ID
     * @param notificationType Notification type
     * @return List of NotificationLogDtos
     */
    List<NotificationLogDto> getNotificationsByType(Long userId, String notificationType);
    
    /**
     * Get notifications related to an entity
     * @param entityId Entity ID
     * @param entityType Entity type
     * @return List of NotificationLogDtos
     */
    List<NotificationLogDto> getNotificationsByEntity(Long entityId, String entityType);
    
    /**
     * Get failed notifications for retry
     * @return List of failed notifications
     */
    List<NotificationLog> getFailedNotificationsForRetry();
    
    /**
     * Update delivery status
     * @param notificationId Notification ID
     * @param status New delivery status
     */
    void updateDeliveryStatus(Long notificationId, String status);
}
