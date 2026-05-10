package com.spring.boot.graduationproject1.dto;

import com.spring.boot.graduationproject1.model.AppointmentStatus;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class AppointmentDto {
    // === RESPONSE DATA (auto-populated) ===
    private Long id;                      // Appointment ID (auto-generated)

    // === PATIENT INPUT (for booking) - ONLY these 3 fields required from client ===
    private String patientFirstName;      // Patient's first name - REQUIRED
    private String patientLastName;       // Patient's last name - REQUIRED
    private String patientPhoneNumber;    // Patient's phone number - REQUIRED (auto-creates patient if not exists)

    // === AUTO-POPULATED FROM REQUEST ===
    private LocalDateTime appointmentDate; // From request.dateTime
    private String requestDescription;     // From request.description

    // === DOCTOR INFO ===
    private String doctorFirstName;
    private String doctorLastName;
    private String doctorPhoneNumber;
    private String doctorCity;

    // === CATEGORY INFO ===
    private String categoryName;

    // === APPOINTMENT DETAILS ===
    private Integer durationMinutes;       // null (not tracked)
    private String notes;                  // null (not tracked)
    private AppointmentStatus status;      // PENDING, APPROVED, DONE, CANCELLED

    // === AUDIT FIELDS ===
    private LocalDateTime createdAt;
    private Boolean isExpired;             // 7-day auto-expiration flag
    private Boolean isHistory;             // Completed/cancelled flag

    // === SNAPSHOTS ===
    private String patientNameSnapshot;
    private String patientPhoneSnapshot;
    private String categorySnapshot;
    private String doctorSnapshot;
}
