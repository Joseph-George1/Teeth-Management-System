package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.dto.AppointmentDto;
import com.spring.boot.graduationproject1.mapper.AppointmentMapper;
import com.spring.boot.graduationproject1.model.*;
import com.spring.boot.graduationproject1.repo.*;
import com.spring.boot.graduationproject1.service.AppointmentService;
import com.spring.boot.graduationproject1.service.NotificationService;
import com.spring.boot.graduationproject1.service.NotificationClientService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import javax.print.Doc;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class AppointmentServiceImpl implements AppointmentService {
    private static final Logger logger = LoggerFactory.getLogger(AppointmentServiceImpl.class);

    private final AppointmentRepo appointmentRepo;
    private final AppointmentMapper appointmentMapper;
    private final DoctorRepo doctorRepo;
    private final PatientRepo patientRepo;
    private final RequestRepo requestRepo;
    private final RoleRepo roleRepo;
    private final NotificationService notificationService;
    private final NotificationClientService notificationClientService;
    private final UserRepo userRepo;

    public AppointmentServiceImpl(AppointmentRepo appointmentRepo, AppointmentMapper appointmentMapper,
                                  DoctorRepo doctorRepo, PatientRepo patientRepo, RequestRepo requestRepo,
                                  RoleRepo roleRepo, NotificationService notificationService,
                                  NotificationClientService notificationClientService, UserRepo userRepo) {
        this.appointmentMapper = appointmentMapper;
        this.appointmentRepo = appointmentRepo;
        this.doctorRepo = doctorRepo;
        this.patientRepo = patientRepo;
        this.requestRepo = requestRepo;
        this.roleRepo = roleRepo;
        this.notificationService = notificationService;
        this.notificationClientService = notificationClientService;
        this.userRepo = userRepo;
    }

    @Override
    public AppointmentDto createAppointment(Long requestId, AppointmentDto appointmentDto) {
        // === STEP 1: Verify request exists and validate it has duration/notes set by doctor ===
        Requests request = requestRepo.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found"));

        Doctor doctor = request.getDoctor();

        // === STEP 2: Validate patient input ===
        if (appointmentDto.getPatientFirstName() == null || appointmentDto.getPatientFirstName().isEmpty()) {
            throw new RuntimeException("Patient first name is required");
        }
        if (appointmentDto.getPatientLastName() == null || appointmentDto.getPatientLastName().isEmpty()) {
            throw new RuntimeException("Patient last name is required");
        }
        if (appointmentDto.getPatientPhoneNumber() == null || appointmentDto.getPatientPhoneNumber().isEmpty()) {
            throw new RuntimeException("Patient phone number is required");
        }

        boolean exists = appointmentRepo.existsByPatientPhoneNumberAndIsHistoryFalseAndIsExpiredFalse(
                appointmentDto.getPatientPhoneNumber());
        if (exists) throw new RuntimeException("Patient already has an active appointment");

        // === STEP 4: Auto-create or get patient by phone number ===


        // === STEP 3: Auto-create or get patient by phone number ===
        Patients patient = patientRepo.findByPhoneNumber(appointmentDto.getPatientPhoneNumber())
                .map(existingPatient -> {
                    existingPatient.setFirstName(appointmentDto.getPatientFirstName());
                    existingPatient.setLastName(appointmentDto.getPatientLastName());
                    return patientRepo.save(existingPatient);
                })
                .orElseGet(() -> {
                    Patients newPatient = new Patients();
                    newPatient.setFirstName(appointmentDto.getPatientFirstName());
                    newPatient.setLastName(appointmentDto.getPatientLastName());
                    newPatient.setPhoneNumber(appointmentDto.getPatientPhoneNumber());

                    Role patientRole = roleRepo.findByName("ROLE_PATIENT")
                            .orElseThrow(() -> new RuntimeException("Role ROLE_PATIENT not found"));

                    newPatient.setRole(patientRole);
                    return patientRepo.save(newPatient);
                });

        // === STEP 4: Create appointment - date/time from REQUEST ===
        Appointments appointment = new Appointments();
        appointment.setDoctor(doctor);
        appointment.setPatient(patient);
        appointment.setRequest(request);
        // 🔥 SNAPSHOT
        appointment.setPatientNameSnapshot(
                appointmentDto.getPatientFirstName() + " " + appointmentDto.getPatientLastName()
        );
        appointment.setPatientPhoneSnapshot(
                appointmentDto.getPatientPhoneNumber()
        );
        appointment.setCategorySnapshot(
                request.getCategory().getName()
        );
        appointment.setDescriptionSnapshot(
                request.getDescription()
        );
        appointment.setAppointmentDate(request.getDateTime()); // Date/time from request
        appointment.setDurationMinutes(null); // No duration tracking
        appointment.setStatus(AppointmentStatus.PENDING);
        appointment.setNotes(null); // No notes tracking
        appointment.setCreatedAt(LocalDateTime.now());
        appointment.setIsExpired(false);
        appointment.setIsHistory(false);

        appointmentRepo.save(appointment);

        // === STEP 5: Send appointment confirmation to Python notification service ===
        try {
            String idempotencyKey = UUID.randomUUID().toString();
            String patientName = appointment.getPatientNameSnapshot();
            String doctorName = doctor.getFirstName() + " " + doctor.getLastName();
            String category = doctor.getCategoryName() != null ? doctor.getCategoryName() : "General";
            String location = doctor.getCityName() != null ? doctor.getCityName() : "Clinic";
            notificationClientService.sendAppointmentConfirmation(
                    appointment.getId(),
                    patient.getId(),
                    patientName,
                    doctor.getId(),
                    doctorName,
                    category,
                    location,
                    idempotencyKey
            );
            logger.info("Appointment notification sent to microservice for appointment ID: {}", appointment.getId());
        } catch (Exception e) {
            logger.warn("Could not send appointment notification to microservice: {}", e.getMessage());
            // Don't fail the appointment creation if notification fails
        }

        // Local notification to doctor
        userRepo.findByEmail(doctor.getEmail()).ifPresent(user -> {
            notificationService.notifyUser(
                    user,
                    "New Appointment",
                    "New request from " + appointment.getPatientNameSnapshot()
            );
        });


        return appointmentMapper.toDto(appointment);
    }

    @Override
    public List<AppointmentDto> getPendingAppointmentsForDoctor() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        Doctor doctor = doctorRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));

        // Get only pending, non-expired, non-history appointments
        List<Appointments> appointments = appointmentRepo.findByDoctorIdAndStatusAndIsHistoryFalse(
                doctor.getId(), AppointmentStatus.PENDING);

        return appointmentMapper.toListDto(appointments);
    }

    @Override
    public AppointmentDto updateAppointmentStatus(Long appointmentId, AppointmentStatus status) {
        Appointments appointment = appointmentRepo.findById(appointmentId)
                .orElseThrow(() -> new RuntimeException("Appointment not found"));

        appointment.setStatus(status);

        // Sync request status
        Requests request = appointment.getRequest();
        if (request != null) {
            if (status == AppointmentStatus.APPROVED) {
                request.setStatus("APPROVED");
            } else if (status == AppointmentStatus.CANCELLED) {
                request.setStatus("CANCELLED");
            } else if (status == AppointmentStatus.DONE) {
                request.setStatus("APPROVED"); // Ensure it remains approved if it was done
            }
            requestRepo.save(request);
        }

        // If approved, delete all other appointments for the same patient
        if (status == AppointmentStatus.APPROVED) {
            List<Appointments> otherAppointments = appointmentRepo.findByPatientId(appointment.getPatient().getId());
            otherAppointments.forEach(app -> {
                if (!app.getId().equals(appointmentId)) {
                    appointmentRepo.delete(app);
                }
            });
            // Clear duration when approved - doctor decides when it's done
            appointment.setDurationMinutes(null);
        }

        // Mark as history when done or cancelled
        if (status == AppointmentStatus.DONE || status == AppointmentStatus.CANCELLED) {
            appointment.setIsHistory(true);
        }

        // Notify doctor about appointment status change (gracefully handle errors)
        try {
            User doctorUser = userRepo.findByEmail(appointment.getDoctor().getEmail())
                    .orElse(null);
            if (doctorUser != null) {
                notificationService.notifyUser(
                        doctorUser,
                        "Appointment " + status.name(),
                        "Appointment with " + appointment.getPatient().getFirstName() + " " + appointment.getPatient().getLastName() + " is " + status.name().toLowerCase()
                );
            }
        } catch (Exception e) {
            logger.warn("Could not send notification for appointment {}: {}", appointmentId, e.getMessage());
            // Don't fail the appointment update if notification fails
        }

        appointmentRepo.save(appointment);
        return appointmentMapper.toDto(appointment);
    }

    @Override
    public List<AppointmentDto> getAppointmentHistory(Long doctorId) {
        // Verify doctor is accessing their own history
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        Doctor doctor = doctorRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));

        // Only allow doctor to view their own history
        if (!doctor.getId().equals(doctorId)) {
            throw new RuntimeException("You can only view your own appointment history");
        }

        // Get all completed/cancelled appointments (history=true)
        List<Appointments> appointments = appointmentRepo.findByDoctorIdAndIsHistory(doctorId, true);
        return appointmentMapper.toListDto(appointments);
    }

    @Override
    @Scheduled(fixedDelay = 3600000) // Run every hour
    public void cancelExpiredAppointments() {
        // Auto-cancel appointments that are PENDING for more than 7 days
        LocalDateTime sevenDaysAgo = LocalDateTime.now().minusDays(7);
        List<Appointments> expiredAppointments = appointmentRepo
                .findByStatusAndIsExpiredFalseAndCreatedAtBefore(AppointmentStatus.PENDING, sevenDaysAgo);

        for (Appointments appointment : expiredAppointments) {
            appointment.setIsExpired(true);
            appointment.setStatus(AppointmentStatus.CANCELLED);
            appointment.setIsHistory(true);
            appointmentRepo.save(appointment);
        }
    }

    @Override
    public void deleteAppointment(Long appointmentId) {
        Appointments appointment = appointmentRepo.findById(appointmentId)
                .orElseThrow(() -> new RuntimeException("Appointment not found"));
        appointmentRepo.delete(appointment);
    }

    @Override
    public List<AppointmentDto> getApprovedAndDoneAppointments() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        Doctor doctor = doctorRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));

        List<Appointments> appointments = appointmentRepo.findByDoctorIdAndStatusIn(
                doctor.getId(),
                List.of(AppointmentStatus.APPROVED, AppointmentStatus.DONE)
        );

        return appointmentMapper.toListDto(appointments);
    }

    @Override
    public List<AppointmentDto> getApprovedAppointments() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        Doctor doctor = doctorRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));

        List<Appointments> appointments = appointmentRepo
                .findByDoctorIdAndStatusAndIsHistoryFalseAndIsExpiredFalse(
                        doctor.getId(),
                        AppointmentStatus.APPROVED
                );

        return appointmentMapper.toListDto(appointments);
    }

    @Override
    public List<AppointmentDto> getDoneAppointments() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        Doctor doctor = doctorRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));

        List<Appointments> appointments = appointmentRepo
                .findByDoctorIdAndStatusAndIsHistoryTrue(
                        doctor.getId(),
                        AppointmentStatus.DONE
                );

        return appointmentMapper.toListDto(appointments);
    }

    @Override
    public List<AppointmentDto> getCancelledAppointments() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email=authentication.getName();

        Doctor doctor=doctorRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));

        List<Appointments> appointments=appointmentRepo
                .findByDoctorIdAndStatusAndIsHistoryTrue(
                        doctor.getId(),
                        AppointmentStatus.CANCELLED
                );

        return appointmentMapper.toListDto(appointments);
    }


}

