package com.spring.boot.graduationproject1.repo;

import com.spring.boot.graduationproject1.model.AppointmentStatus;
import com.spring.boot.graduationproject1.model.Appointments;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface AppointmentRepo extends JpaRepository<Appointments, Long> {
    List<Appointments> findByDoctorId(Long doctorId);
    List<Appointments> findByPatientId(Long patientId);
    List<Appointments> findByStatus(AppointmentStatus status);
    List<Appointments> findByPatientIdAndStatus(Long patientId, AppointmentStatus status);
    List<Appointments> findByStatusAndIsExpiredFalseAndCreatedAtBefore(AppointmentStatus status, LocalDateTime dateTime);
    List<Appointments> findByDoctorIdAndIsHistory(Long doctorId, Boolean isHistory);
    List<Appointments> findByDoctorIdAndStatusAndIsHistoryFalse(Long doctorId, AppointmentStatus status);
    List<Appointments> findByIsExpired(Boolean isExpired);
    Long countByStatus(AppointmentStatus status);
    List<Appointments> findByDoctorIdAndStatusIn(Long doctorId, List<AppointmentStatus> statuses);
    List<Appointments> findByDoctorIdAndStatus(Long doctorId, AppointmentStatus status);
    List<Appointments> findByDoctorIdAndIsHistoryTrue(Long doctorId);
    boolean existsByPatientPhoneNumberAndIsHistoryFalseAndIsExpiredFalse(String phoneNumber);
    List<Appointments> findByAppointmentDateBetween(LocalDateTime start, LocalDateTime end);
    List<Appointments> findByDoctorIdAndStatusAndIsHistoryFalseAndIsExpiredFalse(
            Long doctorId, AppointmentStatus status);
    List<Appointments> findByDoctorIdAndStatusAndIsHistoryTrue(
            Long doctorId, AppointmentStatus status);
    List<Appointments> findByRequestId(Long requestId);
}
