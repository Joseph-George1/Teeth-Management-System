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
    // === PATIENT INPUT (for booking) ===
    private Long patientId;               // Patient ID - REQUIRED for system linkage (no login needed)
    private String patientFirstName;      // Patient's first name - REQUIRED
    private String patientLastName;       // Patient's last name - REQUIRED
    private String patientPhoneNumber;    // Patient's phone number - REQUIRED
    // NOTE: appointmentDate comes from request.dateTime set by doctor, not from patient input

    // === RESPONSE DATA (auto-populated) ===
    private String doctorFirstName;
    private String doctorLastName;
    private String doctorPhoneNumber;
    private String doctorCity;
    private String requestDescription;
    private String categoryName;
    private AppointmentStatus status;
    private LocalDateTime createdAt;
    private Boolean isExpired;
    private Boolean isHistory;
}
