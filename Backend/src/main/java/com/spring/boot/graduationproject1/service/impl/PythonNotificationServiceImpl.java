package com.spring.boot.graduationproject1.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.spring.boot.graduationproject1.service.IPythonNotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Implementation of Python Notification Service Integration
 * Communicates with the Python FastAPI notification service at port 9000
 */
@Service
public class PythonNotificationServiceImpl implements IPythonNotificationService {
    
    private static final Logger logger = LoggerFactory.getLogger(PythonNotificationServiceImpl.class);
    
    @Value("${notification.service.url:http://localhost:9000}")
    private String notificationServiceUrl;
    
    @Value("${notification.service.api-key:thoutha-notification-service-key-2024}")
    private String apiKey;
    
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    
    public PythonNotificationServiceImpl(RestTemplate restTemplate, ObjectMapper objectMapper) {
        this.restTemplate = restTemplate;
        this.objectMapper = objectMapper;
    }
    
    @Override
    public String sendNotification(String deviceToken, String title, String body, Map<String, String> data) {
        try {
            String url = notificationServiceUrl + "/api/notify/send";
            
            Map<String, Object> payload = new HashMap<>();
            payload.put("token", deviceToken);
            payload.put("title", title);
            payload.put("body", body);
            if (data != null) {
                payload.put("data", data);
            }
            
            String jsonPayload = objectMapper.writeValueAsString(payload);
            HttpEntity<String> entity = createHttpEntity(jsonPayload);
            
            ResponseEntity<JsonNode> response = restTemplate.postForEntity(
                url,
                entity,
                JsonNode.class
            );
            
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                JsonNode body_response = response.getBody();
                if (body_response.has("message_id")) {
                    logger.info("✓ Notification sent successfully. Message ID: " + 
                        body_response.get("message_id").asText());
                    return body_response.get("message_id").asText();
                }
            }
            
            logger.error("✗ Failed to send notification to: " + deviceToken);
            return null;
            
        } catch (Exception e) {
            logger.error("✗ Error sending notification: " + e.getMessage(), e);
            return null;
        }
    }
    
    @Override
    public JsonNode sendMulticast(List<String> deviceTokens, String title, String body, Map<String, String> data) {
        try {
            String url = notificationServiceUrl + "/api/notify/send-multicast";
            
            Map<String, Object> payload = new HashMap<>();
            payload.put("tokens", deviceTokens);
            payload.put("title", title);
            payload.put("body", body);
            if (data != null) {
                payload.put("data", data);
            }
            
            String jsonPayload = objectMapper.writeValueAsString(payload);
            HttpEntity<String> entity = createHttpEntity(jsonPayload);
            
            ResponseEntity<JsonNode> response = restTemplate.postForEntity(
                url,
                entity,
                JsonNode.class
            );
            
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                JsonNode responseBody = response.getBody();
                logger.info("✓ Multicast notification sent. Success: " + 
                    responseBody.get("successful") + ", Failed: " + responseBody.get("failed"));
                return responseBody;
            }
            
            logger.error("✗ Failed to send multicast notification");
            return null;
            
        } catch (Exception e) {
            logger.error("✗ Error sending multicast notification: " + e.getMessage(), e);
            return null;
        }
    }
    
    @Override
    public String sendToTopic(String topic, String title, String body, Map<String, String> data) {
        try {
            String url = notificationServiceUrl + "/api/notify/send-to-topic";
            
            Map<String, Object> payload = new HashMap<>();
            payload.put("topic", topic);
            payload.put("title", title);
            payload.put("body", body);
            if (data != null) {
                payload.put("data", data);
            }
            
            String jsonPayload = objectMapper.writeValueAsString(payload);
            HttpEntity<String> entity = createHttpEntity(jsonPayload);
            
            ResponseEntity<JsonNode> response = restTemplate.postForEntity(
                url,
                entity,
                JsonNode.class
            );
            
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                JsonNode responseBody = response.getBody();
                if (responseBody.has("message_id")) {
                    logger.info("✓ Topic notification sent to: " + topic);
                    return responseBody.get("message_id").asText();
                }
            }
            
            logger.error("✗ Failed to send topic notification");
            return null;
            
        } catch (Exception e) {
            logger.error("✗ Error sending topic notification: " + e.getMessage(), e);
            return null;
        }
    }
    
    @Override
    public Boolean subscribeToTopic(List<String> deviceTokens, String topic) {
        try {
            String url = notificationServiceUrl + "/api/notify/subscribe-topic";
            
            Map<String, Object> payload = new HashMap<>();
            payload.put("tokens", deviceTokens);
            payload.put("topic", topic);
            
            String jsonPayload = objectMapper.writeValueAsString(payload);
            HttpEntity<String> entity = createHttpEntity(jsonPayload);
            
            ResponseEntity<JsonNode> response = restTemplate.postForEntity(
                url,
                entity,
                JsonNode.class
            );
            
            if (response.getStatusCode().is2xxSuccessful()) {
                logger.info("✓ Subscribed " + deviceTokens.size() + " devices to topic: " + topic);
                return true;
            }
            
            return false;
            
        } catch (Exception e) {
            logger.error("✗ Error subscribing to topic: " + e.getMessage(), e);
            return false;
        }
    }
    
    @Override
    public Boolean unsubscribeFromTopic(List<String> deviceTokens, String topic) {
        try {
            String url = notificationServiceUrl + "/api/notify/unsubscribe-topic";
            
            Map<String, Object> payload = new HashMap<>();
            payload.put("tokens", deviceTokens);
            payload.put("topic", topic);
            
            String jsonPayload = objectMapper.writeValueAsString(payload);
            HttpEntity<String> entity = createHttpEntity(jsonPayload);
            
            ResponseEntity<JsonNode> response = restTemplate.postForEntity(
                url,
                entity,
                JsonNode.class
            );
            
            if (response.getStatusCode().is2xxSuccessful()) {
                logger.info("✓ Unsubscribed " + deviceTokens.size() + " devices from topic: " + topic);
                return true;
            }
            
            return false;
            
        } catch (Exception e) {
            logger.error("✗ Error unsubscribing from topic: " + e.getMessage(), e);
            return false;
        }
    }
    
    @Override
    public JsonNode getStatistics() {
        try {
            String url = notificationServiceUrl + "/api/notify/statistics";
            
            HttpHeaders headers = new HttpHeaders();
            headers.set("X-API-Key", apiKey);
            
            HttpEntity<String> entity = new HttpEntity<>(headers);
            
            ResponseEntity<JsonNode> response = restTemplate.getForEntity(
                url,
                JsonNode.class
            );
            
            if (response.getStatusCode().is2xxSuccessful()) {
                return response.getBody();
            }
            
            return null;
            
        } catch (Exception e) {
            logger.error("✗ Error fetching statistics: " + e.getMessage(), e);
            return null;
        }
    }
    
    @Override
    public Boolean isServiceHealthy() {
        try {
            String url = notificationServiceUrl + "/api/notify/health";
            
            ResponseEntity<JsonNode> response = restTemplate.getForEntity(
                url,
                JsonNode.class
            );
            
            return response.getStatusCode().is2xxSuccessful();
            
        } catch (Exception e) {
            logger.error("✗ Notification service health check failed: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Create HttpEntity with proper headers
     */
    private HttpEntity<String> createHttpEntity(String jsonPayload) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("X-API-Key", apiKey);
        
        return new HttpEntity<>(jsonPayload, headers);
    }
}
