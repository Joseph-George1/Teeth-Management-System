package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * DeviceToken Entity
 * Stores Firebase Cloud Messaging (FCM) device tokens for push notifications
 * 
 * Each user (Patient or Doctor) can have multiple device tokens
 * (e.g., phone, tablet, web browser)
 */
@Entity
@Table(name = "DEVICE_TOKENS")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class DeviceToken {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    /**
     * Unique FCM device token from Firebase
     * Used to send notifications to specific device
     */
    @Column(name = "TOKEN", nullable = false, unique = true, length = 500)
    private String token;
    
    /**
     * User ID (can be patient or doctor ID)
     * Stored as generic ID to support both Patient and Doctor entities
     */
    @Column(name = "USER_ID", nullable = false)
    private Long userId;
    
    /**
     * Type of user: PATIENT or DOCTOR
     * Determines which table the USER_ID refers to
     */
    @Column(name = "USER_TYPE", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private UserType userType;
    
    /**
     * Device platform: ANDROID, IOS, WEB
     */
    @Column(name = "PLATFORM", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private DevicePlatform platform;
    
    /**
     * Human-readable device name
     * e.g., "iPhone 13", "Samsung Galaxy S21", "Chrome on Windows"
     */
    @Column(name = "DEVICE_NAME", length = 255)
    private String deviceName;
    
    /**
     * Whether this token is currently active
     * Set to false when user logs out from that device
     */
    @Column(name = "IS_ACTIVE", nullable = false)
    private Boolean isActive = true;
    
    /**
     * When this token was registered
     */
    @Column(name = "REGISTERED_AT", nullable = false, updatable = false)
    private LocalDateTime registeredAt = LocalDateTime.now();
    
    /**
     * When this token was last used
     * Helps identify stale tokens
     */
    @Column(name = "LAST_USED_AT")
    private LocalDateTime lastUsedAt;
    
    /**
     * When this token was deactivated/deleted
     * For soft delete pattern
     */
    @Column(name = "DEACTIVATED_AT")
    private LocalDateTime deactivatedAt;
    
    /**
     * Enum for user types
     */
    public enum UserType {
        PATIENT,
        DOCTOR,
        ADMIN
    }
    
    /**
     * Enum for device platforms
     */
    public enum DevicePlatform {
        ANDROID,
        IOS,
        WEB,
        WINDOWS,
        MACOS
    }
}
