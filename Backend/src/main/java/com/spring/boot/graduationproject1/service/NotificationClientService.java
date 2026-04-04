package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.NotificationRequest;
import java.util.Map;

public interface NotificationClientService {
    Map<String, Object> sendAppointmentConfirmation(Long appointmentId, Long patientId, String patientName, Long doctorId, String doctorName, String category, String location, String idempotencyKey);
    Map<String, Object> sendTreatmentPlanUpdate(Long patientId, Long treatmentPlanId);
    Map<String, Object> sendPaymentReceived(Long patientId, String amount);
    Map<String, Object> getNotificationStatus(String fcmMessageId);
    boolean healthCheck();
}
