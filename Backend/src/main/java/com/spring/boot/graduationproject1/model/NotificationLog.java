package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * NotificationLog Entity
 * Tracks all notifications sent to users
 * 
 * Used for:
 * - Audit trail of all notifications sent
 * - Resend functionality
 * - Analytics and reporting
 * - Delivery status tracking
 */
@Entity
@Table(name = "NOTIFICATION_LOGS")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class NotificationLog {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    /**
     * User who received the notification
     */
    @Column(name = "RECIPIENT_USER_ID", nullable = false)
    private Long recipientUserId;
    
    /**
     * Type of recipient: PATIENT, DOCTOR, ADMIN
     */
    @Column(name = "RECIPIENT_USER_TYPE", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private DeviceToken.UserType recipientUserType;
    
    /**
     * Notification title
     */
    @Column(name = "TITLE", nullable = false, length = 255)
    private String title;
    
    /**
     * Notification body/message
     */
    @Column(name = "BODY", nullable = false, length = 1000)
    private String body;
    
    /**
     * Notification type for categorization
     * e.g., APPOINTMENT_CONFIRMED, APPOINTMENT_CANCELLED, 
     *       APPOINTMENT_REMINDER, BOOKING_REQUEST, etc.
     */
    @Column(name = "NOTIFICATION_TYPE", nullable = false, length = 50)
    @Enumerated(EnumType.STRING)
    private NotificationType notificationType;
    
    /**
     * Related entity ID (e.g., Appointment ID, Request ID)
     * Allows tracing notification back to source event
     */
    @Column(name = "RELATED_ENTITY_ID")
    private Long relatedEntityId;
    
    /**
     * Type of related entity
     * e.g., APPOINTMENT, REQUEST, BOOKING, etc.
     */
    @Column(name = "RELATED_ENTITY_TYPE", length = 50)
    private String relatedEntityType;
    
    /**
     * Message ID from Firebase Cloud Messaging
     * Used for tracking delivery status
     */
    @Column(name = "FCM_MESSAGE_ID", length = 255)
    private String fcmMessageId;
    
    /**
     * Delivery status of the notification
     */
    @Column(name = "DELIVERY_STATUS", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private DeliveryStatus deliveryStatus = DeliveryStatus.SENT;
    
    /**
     * Whether user read/viewed the notification
     * May be tracked client-side
     */
    @Column(name = "IS_READ", nullable = false)
    private Boolean isRead = false;
    
    /**
     * When notification was read by user
     */
    @Column(name = "READ_AT")
    private LocalDateTime readAt;
    
    /**
     * Additional data payload sent with notification
     * JSON format
     */
    @Column(name = "DATA_PAYLOAD", length = 2000)
    private String dataPayload;
    
    /**
     * When notification was sent
     */
    @Column(name = "SENT_AT", nullable = false, updatable = false)
    private LocalDateTime sentAt = LocalDateTime.now();
    
    /**
     * When notification record was created
     */
    @Column(name = "CREATED_AT", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
    
    /**
     * Notification types enumeration
     */
    public enum NotificationType {
        APPOINTMENT_CONFIRMED,
        APPOINTMENT_CANCELLED,
        APPOINTMENT_REMINDER,
        APPOINTMENT_RESCHEDULED,
        BOOKING_REQUEST_RECEIVED,
        BOOKING_REQUEST_APPROVED,
        BOOKING_REQUEST_REJECTED,
        BOOKING_REQUEST_PENDING,
        DOCTOR_ACCEPTED_BOOKING,
        DOCTOR_REJECTED_BOOKING,
        PAYMENT_RECEIVED,
        PAYMENT_FAILED,
        PROFILE_UPDATE,
        SYSTEM_ANNOUNCEMENT,
        MESSAGE,
        OTHER
    }
    
    /**
     * Delivery status enumeration
     */
    public enum DeliveryStatus {
        PENDING,        // Waiting to be sent
        SENT,           // Sent to Firebase
        DELIVERED,      // Confirmed delivered to device
        FAILED,         // Failed to send
        BOUNCED,        // Device token invalid
        EXPIRED         // Token expired
    }
}
