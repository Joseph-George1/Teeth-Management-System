package com.spring.boot.graduationproject1.controller;

import com.spring.boot.graduationproject1.dto.AppointmentDto;
import com.spring.boot.graduationproject1.service.AppointmentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/appointment")
public class AppointmentController {
    private AppointmentService appointmentService;

    public AppointmentController(AppointmentService appointmentService) {
        this.appointmentService = appointmentService;
    }

    @GetMapping("/getAllAppointments")
    public ResponseEntity<List<AppointmentDto>>getAllAppointments(){
        return ResponseEntity.ok(appointmentService.getAllAppointments());
    }

    @GetMapping("/getAppointmentsByDoctorId")
    public ResponseEntity<List<AppointmentDto>>getAppointmentsByDoctorId(){
        return ResponseEntity.ok(appointmentService.getAppointmentsByDoctorId());
    }

}
