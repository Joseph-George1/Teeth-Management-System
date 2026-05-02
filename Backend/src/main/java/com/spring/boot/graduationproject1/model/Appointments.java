package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class Appointments {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "doctor_id")
    private Doctor doctor;

    @ManyToOne
    @JoinColumn(name = "patient_id")
    private Patients patient;

    @ManyToOne
    @JoinColumn(name = "request_id", nullable = true)
    private Requests request;

    @Column(nullable = false)
    private LocalDateTime appointmentDate;

    @Column(nullable = true)
    private Integer durationMinutes; // Only set when PENDING, null when APPROVED onwards

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private AppointmentStatus status = AppointmentStatus.PENDING;

    @Column(length = 500)
    private String notes;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(nullable = false)
    private Boolean isExpired = false;

    @Column(nullable = false)
    private Boolean isHistory = false; // Marks completed/cancelled appointments

    // === SNAPSHOTS ===
    @Column(nullable = false)
    private String patientNameSnapshot;

    @Column(nullable = false)
    private String patientPhoneSnapshot;

    @Column(nullable = false)
    private String categorySnapshot;

    @Column(nullable = false)
    private String descriptionSnapshot;
}
