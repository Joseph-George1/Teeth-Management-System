package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.dto.NotificationPreferenceDto;
import com.spring.boot.graduationproject1.mapper.NotificationPreferenceMapper;
import com.spring.boot.graduationproject1.model.NotificationPreference;
import com.spring.boot.graduationproject1.repo.NotificationPreferenceRepo;
import com.spring.boot.graduationproject1.service.INotificationPreferenceService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.LocalTime;

@Service
@Transactional
public class NotificationPreferenceServiceImpl implements INotificationPreferenceService {
    
    private final NotificationPreferenceRepo notificationPreferenceRepo;
    private final NotificationPreferenceMapper notificationPreferenceMapper;
    
    public NotificationPreferenceServiceImpl(NotificationPreferenceRepo notificationPreferenceRepo,
                                           NotificationPreferenceMapper notificationPreferenceMapper) {
        this.notificationPreferenceRepo = notificationPreferenceRepo;
        this.notificationPreferenceMapper = notificationPreferenceMapper;
    }
    
    @Override
    public NotificationPreferenceDto getUserPreferences(Long userId, String userType) {
        return notificationPreferenceRepo.findByUserId(userId)
            .map(notificationPreferenceMapper::toDto)
            .orElseGet(() -> createDefaultPreferences(userId, userType));
    }
    
    private NotificationPreferenceDto createDefaultPreferences(Long userId, String userType) {
        NotificationPreference preference = new NotificationPreference();
        preference.setUserId(userId);
        preference.setUserType(NotificationPreference.UserType.valueOf(userType.toUpperCase()));
        preference.setPushNotificationsEnabled(true);
        preference.setAppointmentConfirmedEnabled(true);
        preference.setAppointmentCancelledEnabled(true);
        preference.setAppointmentReminderEnabled(true);
        preference.setBookingRequestEnabled(true);
        preference.setSystemAnnouncementEnabled(true);
        preference.setPromotionalEnabled(false);
        preference.setQuietHoursStart(null);
        preference.setQuietHoursEnd(null);
        preference.setAllowNotificationsInQuietHours(false);
        preference.setLanguagePreference("en");
        preference.setEmailNotificationsEnabled(false);
        preference.setSmsNotificationsEnabled(false);
        preference.setDailyNotificationLimit(0);
        preference.setUpdatedAt(LocalDateTime.now());
        preference.setCreatedAt(LocalDateTime.now());
        
        NotificationPreference saved = notificationPreferenceRepo.save(preference);
        return notificationPreferenceMapper.toDto(saved);
    }
    
    @Override
    public NotificationPreferenceDto updatePreferences(Long userId, NotificationPreferenceDto preferences) {
        NotificationPreference existing = notificationPreferenceRepo.findByUserId(userId)
            .orElseThrow(() -> new RuntimeException("Preferences not found for user: " + userId));
        
        existing.setPushNotificationsEnabled(preferences.getPushNotificationsEnabled());
        existing.setAppointmentConfirmedEnabled(preferences.getAppointmentConfirmedEnabled());
        existing.setAppointmentCancelledEnabled(preferences.getAppointmentCancelledEnabled());
        existing.setAppointmentReminderEnabled(preferences.getAppointmentReminderEnabled());
        existing.setBookingRequestEnabled(preferences.getBookingRequestEnabled());
        existing.setSystemAnnouncementEnabled(preferences.getSystemAnnouncementEnabled());
        existing.setPromotionalEnabled(preferences.getPromotionalEnabled());
        existing.setQuietHoursStart(preferences.getQuietHoursStart());
        existing.setQuietHoursEnd(preferences.getQuietHoursEnd());
        existing.setAllowNotificationsInQuietHours(preferences.getAllowNotificationsInQuietHours());
        existing.setLanguagePreference(preferences.getLanguagePreference());
        existing.setEmailNotificationsEnabled(preferences.getEmailNotificationsEnabled());
        existing.setSmsNotificationsEnabled(preferences.getSmsNotificationsEnabled());
        existing.setDailyNotificationLimit(preferences.getDailyNotificationLimit());
        existing.setUpdatedAt(LocalDateTime.now());
        
        NotificationPreference updated = notificationPreferenceRepo.save(existing);
        return notificationPreferenceMapper.toDto(updated);
    }
    
    @Override
    public Boolean isNotificationTypeEnabled(Long userId, String notificationType) {
        NotificationPreference pref = notificationPreferenceRepo.findByUserId(userId)
            .orElse(null);
        
        if (pref == null || !pref.getPushNotificationsEnabled()) {
            return false;
        }
        
        return switch (notificationType.toLowerCase()) {
            case "appointment_confirmed" -> pref.getAppointmentConfirmedEnabled();
            case "appointment_cancelled" -> pref.getAppointmentCancelledEnabled();
            case "appointment_reminder" -> pref.getAppointmentReminderEnabled();
            case "booking_request" -> pref.getBookingRequestEnabled();
            case "system_announcement" -> pref.getSystemAnnouncementEnabled();
            case "promotional" -> pref.getPromotionalEnabled();
            default -> true;
        };
    }
    
    @Override
    public Boolean isInQuietHours(Long userId) {
        NotificationPreference pref = notificationPreferenceRepo.findByUserId(userId)
            .orElse(null);
        
        if (pref == null || pref.getQuietHoursStart() == null || pref.getQuietHoursEnd() == null) {
            return false;
        }
        
        if (pref.getAllowNotificationsInQuietHours()) {
            return false;
        }
        
        int currentHour = LocalTime.now().getHour();
        int start = pref.getQuietHoursStart();
        int end = pref.getQuietHoursEnd();
        
        // Handle cases like quiet hours from 22 (10 PM) to 8 (8 AM)
        if (start > end) {
            return currentHour >= start || currentHour < end;
        } else {
            return currentHour >= start && currentHour < end;
        }
    }
    
    @Override
    public NotificationPreferenceDto resetToDefaults(Long userId) {
        NotificationPreference existing = notificationPreferenceRepo.findByUserId(userId)
            .orElse(null);
        
        if (existing != null) {
            existing.setPushNotificationsEnabled(true);
            existing.setAppointmentConfirmedEnabled(true);
            existing.setAppointmentCancelledEnabled(true);
            existing.setAppointmentReminderEnabled(true);
            existing.setBookingRequestEnabled(true);
            existing.setSystemAnnouncementEnabled(true);
            existing.setPromotionalEnabled(false);
            existing.setQuietHoursStart(null);
            existing.setQuietHoursEnd(null);
            existing.setAllowNotificationsInQuietHours(false);
            existing.setLanguagePreference("en");
            existing.setEmailNotificationsEnabled(false);
            existing.setSmsNotificationsEnabled(false);
            existing.setDailyNotificationLimit(0);
            existing.setUpdatedAt(LocalDateTime.now());
            
            NotificationPreference updated = notificationPreferenceRepo.save(existing);
            return notificationPreferenceMapper.toDto(updated);
        }
        
        return null;
    }
}
