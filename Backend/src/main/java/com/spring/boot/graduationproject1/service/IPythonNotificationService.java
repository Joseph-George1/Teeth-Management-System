package com.spring.boot.graduationproject1.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.spring.boot.graduationproject1.dto.NotificationLogDto;

import java.util.List;
import java.util.Map;

/**
 * Interface for Python Notification Service Integration
 * Handles communication with Python FastAPI notification service
 */
public interface IPythonNotificationService {
    
    /**
     * Send notification to single device
     * @param deviceToken Firebase device token
     * @param title Notification title
     * @param body Notification body
     * @param data Optional data payload
     * @return FCM message ID if successful, null if failed
     */
    String sendNotification(String deviceToken, String title, String body, Map<String, String> data);
    
    /**
     * Send notification to multiple devices
     * @param deviceTokens List of Firebase device tokens
     * @param title Notification title
     * @param body Notification body
     * @param data Optional data payload
     * @return JsonNode with success/failure counts
     */
    JsonNode sendMulticast(List<String> deviceTokens, String title, String body, Map<String, String> data);
    
    /**
     * Send notification to all subscribers of a topic
     * @param topic Topic name
     * @param title Notification title
     * @param body Notification body
     * @param data Optional data payload
     * @return FCM message ID if successful
     */
    String sendToTopic(String topic, String title, String body, Map<String, String> data);
    
    /**
     * Subscribe device to topic
     * @param deviceTokens List of device tokens
     * @param topic Topic name
     * @return True if successful
     */
    Boolean subscribeToTopic(List<String> deviceTokens, String topic);
    
    /**
     * Unsubscribe device from topic
     * @param deviceTokens List of device tokens
     * @param topic Topic name
     * @return True if successful
     */
    Boolean unsubscribeFromTopic(List<String> deviceTokens, String topic);
    
    /**
     * Get notification service statistics
     * @return Statistics JsonNode
     */
    JsonNode getStatistics();
    
    /**
     * Check if notification service is healthy
     * @return True if service is responding
     */
    Boolean isServiceHealthy();
}
