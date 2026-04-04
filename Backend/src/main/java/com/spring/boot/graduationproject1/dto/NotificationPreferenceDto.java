package com.spring.boot.graduationproject1.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * DTO for NotificationPreference
 * Used for API requests/responses
 */
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class NotificationPreferenceDto {
    
    private Long id;
    private Boolean pushNotificationsEnabled;
    private Boolean appointmentConfirmedEnabled;
    private Boolean appointmentCancelledEnabled;
    private Boolean appointmentReminderEnabled;
    private Boolean bookingRequestEnabled;
    private Boolean systemAnnouncementEnabled;
    private Boolean promotionalEnabled;
    private Integer quietHoursStart;
    private Integer quietHoursEnd;
    private Boolean allowNotificationsInQuietHours;
    private String languagePreference;
    private Boolean emailNotificationsEnabled;
    private Boolean smsNotificationsEnabled;
    private Integer dailyNotificationLimit;
}
