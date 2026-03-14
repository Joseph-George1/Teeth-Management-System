package com.spring.boot.graduationproject1.controller;

import com.spring.boot.graduationproject1.dto.AppointmentDto;
import com.spring.boot.graduationproject1.service.AppointmentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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

    @PostMapping("/createAppointment")
    public ResponseEntity<AppointmentDto>createAppointment(@RequestBody AppointmentDto appointmentDto){
        return ResponseEntity.ok(appointmentService.createAppointment(appointmentDto));
    }

    @GetMapping("/getAppointmentById")
    public ResponseEntity<AppointmentDto>getAppointmentById(@RequestParam Long id){
        return ResponseEntity.ok(appointmentService.getAppointmentById(id));
    }

}
