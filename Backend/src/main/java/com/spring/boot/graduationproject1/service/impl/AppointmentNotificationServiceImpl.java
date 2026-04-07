package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.model.Appointments;
import com.spring.boot.graduationproject1.service.AppointmentNotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class AppointmentNotificationServiceImpl implements AppointmentNotificationService {
    private static final Logger logger = LoggerFactory.getLogger(AppointmentNotificationServiceImpl.class);

    private final NotificationClientServiceImpl notificationClientService;

    public AppointmentNotificationServiceImpl(NotificationClientServiceImpl notificationClientService) {
        this.notificationClientService = notificationClientService;
    }

    @Override
    public void notifyAppointmentCreated(Appointments appointment) {
        try {
            String idempotencyKey = generateIdempotencyKey(appointment.getId(), "created");
            String patientName = appointment.getPatient().getFirstName() + " " + appointment.getPatient().getLastName();
            String doctorName = appointment.getDoctor().getFirstName() + " " + appointment.getDoctor().getLastName();
            String category = appointment.getDoctor().getCategoryName() != null ? appointment.getDoctor().getCategoryName() : "General";
            String location = appointment.getDoctor().getCityName() != null ? appointment.getDoctor().getCityName() : "Clinic";
            
            notificationClientService.sendAppointmentConfirmation(
                    appointment.getId(),
                    appointment.getPatient().getId(),
                    patientName,
                    appointment.getDoctor().getId(),
                    doctorName,
                    category,
                    location,
                    idempotencyKey
            );
            
            logger.info("Appointment created notification sent for appointment: {}", appointment.getId());
        } catch (Exception e) {
            logger.error("Error sending appointment created notification: {}", e.getMessage(), e);
        }
    }

    @Override
    public void notifyAppointmentApproved(Appointments appointment) {
        try {
            String idempotencyKey = generateIdempotencyKey(appointment.getId(), "approved");
            String patientName = appointment.getPatient().getFirstName() + " " + appointment.getPatient().getLastName();
            String doctorName = appointment.getDoctor().getFirstName() + " " + appointment.getDoctor().getLastName();
            String category = appointment.getDoctor().getCategoryName() != null ? appointment.getDoctor().getCategoryName() : "General";
            String location = appointment.getDoctor().getCityName() != null ? appointment.getDoctor().getCityName() : "Clinic";
            
            notificationClientService.sendAppointmentConfirmation(
                    appointment.getId(),
                    appointment.getPatient().getId(),
                    patientName,
                    appointment.getDoctor().getId(),
                    doctorName,
                    category,
                    location,
                    idempotencyKey
            );
            
            logger.info("Appointment approved notification sent for appointment: {}", appointment.getId());
        } catch (Exception e) {
            logger.error("Error sending appointment approved notification: {}", e.getMessage(), e);
        }
    }

    @Override
    public void notifyAppointmentCancelled(Appointments appointment) {
        try {
            String idempotencyKey = generateIdempotencyKey(appointment.getId(), "cancelled");
            String patientName = appointment.getPatient().getFirstName() + " " + appointment.getPatient().getLastName();
            String doctorName = appointment.getDoctor().getFirstName() + " " + appointment.getDoctor().getLastName();
            String category = appointment.getDoctor().getCategoryName() != null ? appointment.getDoctor().getCategoryName() : "General";
            String location = appointment.getDoctor().getCityName() != null ? appointment.getDoctor().getCityName() : "Clinic";
            
            // For now, use the generic confirmation endpoint
            // In future, create a dedicated cancellation endpoint in Python service
            notificationClientService.sendAppointmentConfirmation(
                    appointment.getId(),
                    appointment.getPatient().getId(),
                    patientName,
                    appointment.getDoctor().getId(),
                    doctorName,
                    category,
                    location,
                    idempotencyKey
            );
            
            logger.info("Appointment cancelled notification sent for appointment: {}", appointment.getId());
        } catch (Exception e) {
            logger.error("Error sending appointment cancelled notification: {}", e.getMessage(), e);
        }
    }

    @Override
    public void notifyAppointmentDone(Appointments appointment) {
        try {
            String idempotencyKey = generateIdempotencyKey(appointment.getId(), "done");
            String patientName = appointment.getPatient().getFirstName() + " " + appointment.getPatient().getLastName();
            String doctorName = appointment.getDoctor().getFirstName() + " " + appointment.getDoctor().getLastName();
            String category = appointment.getDoctor().getCategoryName() != null ? appointment.getDoctor().getCategoryName() : "General";
            String location = appointment.getDoctor().getCityName() != null ? appointment.getDoctor().getCityName() : "Clinic";
            
            notificationClientService.sendAppointmentConfirmation(
                    appointment.getId(),
                    appointment.getPatient().getId(),
                    patientName,
                    appointment.getDoctor().getId(),
                    doctorName,
                    category,
                    location,
                    idempotencyKey
            );
            
            logger.info("Appointment done notification sent for appointment: {}", appointment.getId());
        } catch (Exception e) {
            logger.error("Error sending appointment done notification: {}", e.getMessage(), e);
        }
    }

    private String generateIdempotencyKey(Long appointmentId, String action) {
        return String.format("%d-%s-%d", appointmentId, action, System.currentTimeMillis() / 1000);
    }
}
