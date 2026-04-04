package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * NotificationPreference Entity
 * Stores user preferences for receiving notifications
 * 
 * Allows users to:
 * - Enable/disable notification types
 * - Set quiet hours (do not disturb)
 * - Choose notification channels
 * - Manage notification frequency
 */
@Entity
@Table(name = "NOTIFICATION_PREFERENCES")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class NotificationPreference {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    /**
     * User ID (Patient, Doctor, or Admin)
     */
    @Column(name = "USER_ID", nullable = false, unique = true)
    private Long userId;
    
    /**
     * Type of user: PATIENT or DOCTOR
     */
    @Column(name = "USER_TYPE", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private DeviceToken.UserType userType;
    
    /**
     * Whether push notifications are globally enabled
     */
    @Column(name = "PUSH_NOTIFICATIONS_ENABLED", nullable = false)
    private Boolean pushNotificationsEnabled = true;
    
    /**
     * Whether appointment confirmations are enabled
     */
    @Column(name = "APPOINTMENT_CONFIRMED_ENABLED", nullable = false)
    private Boolean appointmentConfirmedEnabled = true;
    
    /**
     * Whether appointment cancellation notifications are enabled
     */
    @Column(name = "APPOINTMENT_CANCELLED_ENABLED", nullable = false)
    private Boolean appointmentCancelledEnabled = true;
    
    /**
     * Whether appointment reminders are enabled
     */
    @Column(name = "APPOINTMENT_REMINDER_ENABLED", nullable = false)
    private Boolean appointmentReminderEnabled = true;
    
    /**
     * Whether booking request notifications are enabled
     */
    @Column(name = "BOOKING_REQUEST_ENABLED", nullable = false)
    private Boolean bookingRequestEnabled = true;
    
    /**
     * Whether system announcements are enabled
     */
    @Column(name = "SYSTEM_ANNOUNCEMENT_ENABLED", nullable = false)
    private Boolean systemAnnouncementEnabled = true;
    
    /**
     * Whether promotional/marketing notifications are enabled
     */
    @Column(name = "PROMOTIONAL_ENABLED", nullable = false)
    private Boolean promotionalEnabled = false;
    
    /**
     * Start hour for quiet period (24-hour format)
     * e.g., 22 for 10 PM
     * Set to null to disable quiet hours
     */
    @Column(name = "QUIET_HOURS_START")
    private Integer quietHoursStart;
    
    /**
     * End hour for quiet period (24-hour format)
     * e.g., 8 for 8 AM
     */
    @Column(name = "QUIET_HOURS_END")
    private Integer quietHoursEnd;
    
    /**
     * Whether to send notifications during quiet hours
     */
    @Column(name = "ALLOW_NOTIFICATIONS_IN_QUIET_HOURS", nullable = false)
    private Boolean allowNotificationsInQuietHours = false;
    
    /**
     * Preferred language for notifications
     * e.g., en_US, ar_SA, etc.
     */
    @Column(name = "LANGUAGE_PREFERENCE", length = 10)
    private String languagePreference = "en";
    
    /**
     * Whether to receive notifications via email
     */
    @Column(name = "EMAIL_NOTIFICATIONS_ENABLED", nullable = false)
    private Boolean emailNotificationsEnabled = false;
    
    /**
     * Whether to receive notifications via SMS (if available)
     */
    @Column(name = "SMS_NOTIFICATIONS_ENABLED", nullable = false)
    private Boolean smsNotificationsEnabled = false;
    
    /**
     * Maximum notifications per day
     * Set to 0 for unlimited
     */
    @Column(name = "DAILY_NOTIFICATION_LIMIT")
    private Integer dailyNotificationLimit = 0;
    
    /**
     * When preferences were last updated
     */
    @Column(name = "UPDATED_AT", nullable = false)
    private LocalDateTime updatedAt = LocalDateTime.now();
    
    /**
     * When preferences were created
     */
    @Column(name = "CREATED_AT", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
