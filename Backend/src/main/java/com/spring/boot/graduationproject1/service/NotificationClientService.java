/*
 * Copyright (c) 2026 Muhammad Ashraf Tawfik Elkateb
 * GitHub: https://github.com/MuhammamdElKateb
 */
package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.NotificationRequest;
import java.util.Map;

public interface NotificationClientService {
    Map<String, Object> sendAppointmentConfirmation(Long appointmentId, Long patientId, String patientName, String patientPhone, Long doctorId, String doctorName, String category, String location, String idempotencyKey, String triggerType);
    Map<String, Object> sendTreatmentPlanUpdate(Long patientId, Long treatmentPlanId);
    Map<String, Object> sendPaymentReceived(Long patientId, String amount);
    Map<String, Object> getNotificationStatus(String fcmMessageId);
    boolean healthCheck();
}
