package com.spring.boot.graduationproject1.controller;

import com.spring.boot.graduationproject1.dto.AppointmentDto;
import com.spring.boot.graduationproject1.model.AppointmentStatus;
import com.spring.boot.graduationproject1.service.AppointmentService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/appointment")
public class AppointmentController {
    private AppointmentService appointmentService;

    public AppointmentController(AppointmentService appointmentService) {
        this.appointmentService = appointmentService;
    }

    @PostMapping("/createAppointment/{requestId}")
    public ResponseEntity<AppointmentDto> createAppointment(
            @PathVariable Long requestId,
            @RequestBody AppointmentDto appointmentDto) {
        return ResponseEntity.ok(appointmentService.createAppointment(requestId, appointmentDto));
    }

    @GetMapping("/pendingAppointments")
    public ResponseEntity<List<AppointmentDto>> getPendingAppointmentsForDoctor() {
        return ResponseEntity.ok(appointmentService.getPendingAppointmentsForDoctor());
    }

    @PutMapping("/updateStatus/{appointmentId}")
    public ResponseEntity<AppointmentDto> updateAppointmentStatus(
            @PathVariable Long appointmentId,
            @RequestParam AppointmentStatus status) {
        return ResponseEntity.ok(appointmentService.updateAppointmentStatus(appointmentId, status));
    }

    @GetMapping("/history/{doctorId}")
    public ResponseEntity<List<AppointmentDto>> getAppointmentHistory(
            @PathVariable Long doctorId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new RuntimeException("JWT token required - Authorization header missing");
        }
        return ResponseEntity.ok(appointmentService.getAppointmentHistory(doctorId));
    }

    @DeleteMapping("/deleteAppointment/{appointmentId}")
    public ResponseEntity<Void> deleteAppointment(@PathVariable Long appointmentId) {
        appointmentService.deleteAppointment(appointmentId);
        return ResponseEntity.noContent().build();
    }
}
