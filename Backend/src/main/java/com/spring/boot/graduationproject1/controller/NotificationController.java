package com.spring.boot.graduationproject1.controller;

import com.spring.boot.graduationproject1.dto.DeviceTokenDto;
import com.spring.boot.graduationproject1.dto.NotificationLogDto;
import com.spring.boot.graduationproject1.dto.NotificationPreferenceDto;
import com.spring.boot.graduationproject1.dto.RegisterDeviceTokenRequest;
import com.spring.boot.graduationproject1.service.IDeviceTokenService;
import com.spring.boot.graduationproject1.service.INotificationLogService;
import com.spring.boot.graduationproject1.service.INotificationPreferenceService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * REST Controller for Notification Management
 * Endpoints for device tokens, notification preferences, and notification history
 */
@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:3000", 
                        "https://www.thoutha.page", "https://thoutha.page"})
public class NotificationController {
    
    private static final Logger logger = LoggerFactory.getLogger(NotificationController.class);
    
    private final IDeviceTokenService deviceTokenService;
    private final INotificationLogService notificationLogService;
    private final INotificationPreferenceService notificationPreferenceService;
    
    public NotificationController(
        IDeviceTokenService deviceTokenService,
        INotificationLogService notificationLogService,
        INotificationPreferenceService notificationPreferenceService
    ) {
        this.deviceTokenService = deviceTokenService;
        this.notificationLogService = notificationLogService;
        this.notificationPreferenceService = notificationPreferenceService;
    }
    
    // ==================== DEVICE TOKEN ENDPOINTS ====================
    
    /**
     * Register a new device token
     * POST /api/notifications/register-device
     * 
     * Request body:
     * {
     *   "token": "FCM_DEVICE_TOKEN",
     *   "platform": "ANDROID|IOS|WEB",
     *   "deviceName": "My iPhone"
     * }
     */
    @PostMapping("/register-device")
    public ResponseEntity<?> registerDeviceToken(@RequestBody RegisterDeviceTokenRequest request) {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            Long userId = Long.parseLong(auth.getPrincipal().toString());
            String userType = auth.getAuthorities().stream()
                .findFirst()
                .map(a -> a.getAuthority().replace("ROLE_", ""))
                .orElse("PATIENT");
            
            DeviceTokenDto deviceToken = deviceTokenService.registerDeviceToken(userId, userType, request);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Device token registered successfully");
            response.put("data", deviceToken);
            
            logger.info("✓ Device token registered for user: " + userId);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("✗ Error registering device token: " + e.getMessage());
            Map<String, String> error = new HashMap<>();
            error.put("success", "false");
            error.put("message", "Failed to register device token: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }
    }
    
    /**
     * Get all active device tokens for current user
     * GET /api/notifications/devices/active
     */
    @GetMapping("/devices/active")
    public ResponseEntity<?> getActiveDevices() {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            Long userId = Long.parseLong(auth.getPrincipal().toString());
            String userType = auth.getAuthorities().stream()
                .findFirst()
                .map(a -> a.getAuthority().replace("ROLE_", ""))
                .orElse("PATIENT");
            
            List<DeviceTokenDto> devices = deviceTokenService.getActiveDeviceTokens(userId, userType);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("count", devices.size());
            response.put("data", devices);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("✗ Error fetching devices: " + e.getMessage());
            Map<String, String> error = new HashMap<>();
            error.put("success", "false");
            error.put("message", "Failed to fetch devices");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * Get all device tokens for current user (active and inactive)
     * GET /api/notifications/devices/all
     */
    @GetMapping("/devices/all")
    public ResponseEntity<?> getAllDevices() {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            Long userId = Long.parseLong(auth.getPrincipal().toString());
            String userType = auth.getAuthorities().stream()
                .findFirst()
                .map(a -> a.getAuthority().replace("ROLE_", ""))
                .orElse("PATIENT");
            
            List<DeviceTokenDto> devices = deviceTokenService.getAllDeviceTokens(userId, userType);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("count", devices.size());
            response.put("data", devices);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("✗ Error fetching all devices: " + e.getMessage());
            Map<String, String> error = new HashMap<>();
            error.put("success", "false");
            error.put("message", "Failed to fetch devices");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * Logout from a device (deactivate token)
     * POST /api/notifications/logout-device/{tokenId}
     */
    @PostMapping("/logout-device/{tokenId}")
    public ResponseEntity<?> logoutDevice(@PathVariable Long tokenId) {
        try {
            Boolean success = deviceTokenService.removeDeviceToken(tokenId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", success);
            response.put("message", success ? "Device logged out successfully" : "Device not found");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("✗ Error logging out device: " + e.getMessage());
            Map<String, String> error = new HashMap<>();
            error.put("success", "false");
            error.put("message", "Failed to logout device");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    // ==================== NOTIFICATION PREFERENCES ENDPOINTS ====================
    
    /**
     * Get notification preferences for current user
     * GET /api/notifications/preferences
     */
    @GetMapping("/preferences")
    public ResponseEntity<?> getPreferences() {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            Long userId = Long.parseLong(auth.getPrincipal().toString());
            String userType = auth.getAuthorities().stream()
                .findFirst()
                .map(a -> a.getAuthority().replace("ROLE_", ""))
                .orElse("PATIENT");
            
            NotificationPreferenceDto preferences = notificationPreferenceService.getUserPreferences(userId, userType);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", preferences);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("✗ Error fetching preferences: " + e.getMessage());
            Map<String, String> error = new HashMap<>();
            error.put("success", "false");
            error.put("message", "Failed to fetch preferences");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * Update notification preferences
     * PUT /api/notifications/preferences
     */
    @PutMapping("/preferences")
    public ResponseEntity<?> updatePreferences(@RequestBody NotificationPreferenceDto preferences) {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            Long userId = Long.parseLong(auth.getPrincipal().toString());
            
            NotificationPreferenceDto updated = notificationPreferenceService.updatePreferences(userId, preferences);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Preferences updated successfully");
            response.put("data", updated);
            
            logger.info("✓ Preferences updated for user: " + userId);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("✗ Error updating preferences: " + e.getMessage());
            Map<String, String> error = new HashMap<>();
            error.put("success", "false");
            error.put("message", "Failed to update preferences: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }
    }
    
    /**
     * Reset preferences to defaults
     * POST /api/notifications/preferences/reset
     */
    @PostMapping("/preferences/reset")
    public ResponseEntity<?> resetPreferences() {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            Long userId = Long.parseLong(auth.getPrincipal().toString());
            
            NotificationPreferenceDto reset = notificationPreferenceService.resetToDefaults(userId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Preferences reset to defaults");
            response.put("data", reset);
            
            logger.info("✓ Preferences reset for user: " + userId);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("✗ Error resetting preferences: " + e.getMessage());
            Map<String, String> error = new HashMap<>();
            error.put("success", "false");
            error.put("message", "Failed to reset preferences");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    // ==================== NOTIFICATION HISTORY ENDPOINTS ====================
    
    /**
     * Get all notifications for current user
     * GET /api/notifications/history
     */
    @GetMapping("/history")
    public ResponseEntity<?> getNotificationHistory() {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            Long userId = Long.parseLong(auth.getPrincipal().toString());
            String userType = auth.getAuthorities().stream()
                .findFirst()
                .map(a -> a.getAuthority().replace("ROLE_", ""))
                .orElse("PATIENT");
            
            List<NotificationLogDto> notifications = notificationLogService.getUserNotifications(userId, userType);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("count", notifications.size());
            response.put("data", notifications);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("✗ Error fetching notification history: " + e.getMessage());
            Map<String, String> error = new HashMap<>();
            error.put("success", "false");
            error.put("message", "Failed to fetch history");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * Get unread notifications for current user
     * GET /api/notifications/unread
     */
    @GetMapping("/unread")
    public ResponseEntity<?> getUnreadNotifications() {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            Long userId = Long.parseLong(auth.getPrincipal().toString());
            String userType = auth.getAuthorities().stream()
                .findFirst()
                .map(a -> a.getAuthority().replace("ROLE_", ""))
                .orElse("PATIENT");
            
            List<NotificationLogDto> unread = notificationLogService.getUnreadNotifications(userId, userType);
            Long count = notificationLogService.countUnreadNotifications(userId, userType);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("unreadCount", count);
            response.put("data", unread);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("✗ Error fetching unread notifications: " + e.getMessage());
            Map<String, String> error = new HashMap<>();
            error.put("success", "false");
            error.put("message", "Failed to fetch unread notifications");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * Mark notification as read
     * POST /api/notifications/{notificationId}/read
     */
    @PostMapping("/{notificationId}/read")
    public ResponseEntity<?> markAsRead(@PathVariable Long notificationId) {
        try {
            notificationLogService.markAsRead(notificationId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Notification marked as read");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("✗ Error marking notification as read: " + e.getMessage());
            Map<String, String> error = new HashMap<>();
            error.put("success", "false");
            error.put("message", "Failed to mark notification as read");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
}
