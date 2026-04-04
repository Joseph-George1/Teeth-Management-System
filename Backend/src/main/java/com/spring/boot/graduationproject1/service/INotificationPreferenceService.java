package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.NotificationPreferenceDto;

/**
 * Interface for Notification Preference Service
 * Manages user notification preferences
 */
public interface INotificationPreferenceService {
    
    /**
     * Get user's notification preferences
     * Creates default if doesn't exist
     * @param userId User ID
     * @param userType Type of user (PATIENT, DOCTOR)
     * @return NotificationPreferenceDto
     */
    NotificationPreferenceDto getUserPreferences(Long userId, String userType);
    
    /**
     * Update user's notification preferences
     * @param userId User ID
     * @param preferences Updated preferences
     * @return Updated NotificationPreferenceDto
     */
    NotificationPreferenceDto updatePreferences(Long userId, NotificationPreferenceDto preferences);
    
    /**
     * Check if user has specific notification type enabled
     * @param userId User ID
     * @param notificationType Type of notification to check
     * @return True if enabled
     */
    Boolean isNotificationTypeEnabled(Long userId, String notificationType);
    
    /**
     * Check if it's quiet hours for user
     * @param userId User ID
     * @return True if within quiet hours and notifications should be suppressed
     */
    Boolean isInQuietHours(Long userId);
    
    /**
     * Reset preferences to defaults
     * @param userId User ID
     * @return Reset NotificationPreferenceDto
     */
    NotificationPreferenceDto resetToDefaults(Long userId);
}
