package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.service.NotificationClientService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.RestClientException;

import java.util.*;

@Service
public class NotificationClientServiceImpl implements NotificationClientService {
    private static final Logger logger = LoggerFactory.getLogger(NotificationClientServiceImpl.class);

    @Value("${notification.service.url:http://localhost:9000}")
    private String notificationServiceUrl;

    private final RestTemplate restTemplate;

    public NotificationClientServiceImpl(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @Override
    public Map<String, Object> sendAppointmentConfirmation(Long appointmentId, Long patientId, 
                                                           Long doctorId, String idempotencyKey) {
        try {
            String url = notificationServiceUrl + "/api/v1/notifications/appointment-confirmed";
            
            Map<String, Object> payload = new HashMap<>();
            payload.put("appointment_id", appointmentId);
            payload.put("patient_id", patientId);
            payload.put("doctor_id", doctorId);
            payload.put("idempotency_key", idempotencyKey);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Idempotency-Key", idempotencyKey);
            
            HttpEntity<Map<String, Object>> request = new HttpEntity<>(payload, headers);
            
            ResponseEntity<Map> response = restTemplate.postForEntity(url, request, Map.class);
            
            logger.info("Appointment confirmation sent. Status: {}", response.getStatusCode());
            return response.getBody();
            
        } catch (RestClientException e) {
            logger.error("Failed to send appointment confirmation: {}", e.getMessage(), e);
            return Map.of("success", false, "error", e.getMessage());
        }
    }

    @Override
    public Map<String, Object> sendTreatmentPlanUpdate(Long patientId, Long treatmentPlanId) {
        try {
            String url = notificationServiceUrl + "/api/v1/notifications/treatment-plan-update?patient_id=" 
                        + patientId + "&treatment_plan_id=" + treatmentPlanId;
            
            ResponseEntity<Map> response = restTemplate.postForEntity(url, null, Map.class);
            
            logger.info("Treatment plan update sent. Status: {}", response.getStatusCode());
            return response.getBody();
            
        } catch (RestClientException e) {
            logger.error("Failed to send treatment plan update: {}", e.getMessage(), e);
            return Map.of("success", false, "error", e.getMessage());
        }
    }

    @Override
    public Map<String, Object> sendPaymentReceived(Long patientId, String amount) {
        try {
            String url = notificationServiceUrl + "/api/v1/notifications/payment-received?patient_id=" 
                        + patientId + "&amount=" + amount;
            
            ResponseEntity<Map> response = restTemplate.postForEntity(url, null, Map.class);
            
            logger.info("Payment notification sent. Status: {}", response.getStatusCode());
            return response.getBody();
            
        } catch (RestClientException e) {
            logger.error("Failed to send payment notification: {}", e.getMessage(), e);
            return Map.of("success", false, "error", e.getMessage());
        }
    }

    @Override
    public Map<String, Object> getNotificationStatus(String fcmMessageId) {
        try {
            String url = notificationServiceUrl + "/api/v1/notifications/status/" + fcmMessageId;
            
            ResponseEntity<Map> response = restTemplate.getForEntity(url, Map.class);
            
            logger.info("Notification status retrieved. Status: {}", response.getStatusCode());
            return response.getBody();
            
        } catch (RestClientException e) {
            logger.error("Failed to get notification status: {}", e.getMessage(), e);
            return null;
        }
    }

    @Override
    public boolean healthCheck() {
        try {
            String url = notificationServiceUrl + "/health";
            ResponseEntity<Map> response = restTemplate.getForEntity(url, Map.class);
            
            if (response.getStatusCode() == HttpStatus.OK) {
                logger.info("Notification service health check passed");
                return true;
            }
            return false;
            
        } catch (RestClientException e) {
            logger.warn("Notification service health check failed: {}", e.getMessage());
            return false;
        }
    }
}
