package com.spring.boot.graduationproject1.controller;

import com.spring.boot.graduationproject1.service.impl.NotificationClientServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*")
public class NotificationController {
    private static final Logger logger = LoggerFactory.getLogger(NotificationController.class);

    private final NotificationClientServiceImpl notificationClientService;

    public NotificationController(NotificationClientServiceImpl notificationClientService) {
        this.notificationClientService = notificationClientService;
    }

    @PostMapping("/appointment-confirmed")
    public ResponseEntity<Map<String, Object>> notifyAppointmentConfirmed(
            @RequestParam Long appointmentId,
            @RequestParam Long patientId,
            @RequestParam String patientName,
            @RequestParam Long doctorId,
            @RequestParam String doctorName,
            @RequestParam String category,
            @RequestParam String location) {
        try {
            String idempotencyKey = UUID.randomUUID().toString();
            Map<String, Object> response = notificationClientService.sendAppointmentConfirmation(
                    appointmentId, patientId, patientName, doctorId, doctorName, category, location, idempotencyKey);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Error notifying appointment confirmation: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @PostMapping("/treatment-plan-update")
    public ResponseEntity<Map<String, Object>> notifyTreatmentPlanUpdate(
            @RequestParam Long patientId,
            @RequestParam Long treatmentPlanId) {
        try {
            Map<String, Object> response = notificationClientService.sendTreatmentPlanUpdate(
                    patientId, treatmentPlanId);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Error notifying treatment plan update: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @PostMapping("/payment-received")
    public ResponseEntity<Map<String, Object>> notifyPaymentReceived(
            @RequestParam Long patientId,
            @RequestParam String amount) {
        try {
            Map<String, Object> response = notificationClientService.sendPaymentReceived(
                    patientId, amount);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Error notifying payment: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @GetMapping("/status/{fcmMessageId}")
    public ResponseEntity<Map<String, Object>> getNotificationStatus(
            @PathVariable String fcmMessageId) {
        try {
            Map<String, Object> response = notificationClientService.getNotificationStatus(fcmMessageId);
            
            if (response == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(Map.of("success", false, "message", "Notification not found"));
            }
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Error getting notification status: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        try {
            boolean healthy = notificationClientService.healthCheck();
            
            if (healthy) {
                return ResponseEntity.ok(Map.of(
                        "status", "healthy",
                        "service", "notification-microservice",
                        "timestamp", System.currentTimeMillis()
                ));
            } else {
                return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                        .body(Map.of(
                                "status", "unhealthy",
                                "message", "Notification service is unavailable"
                        ));
            }
        } catch (Exception e) {
            logger.error("Health check error: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(Map.of(
                            "status", "error",
                            "error", e.getMessage()
                    ));
        }
    }
}
