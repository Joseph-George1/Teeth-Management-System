package com.spring.boot.graduationproject1.controller;

import com.spring.boot.graduationproject1.dto.AppointmentDto;
import com.spring.boot.graduationproject1.dto.RequestDto;
import com.spring.boot.graduationproject1.service.AdminService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {
    private AdminService adminService;

    public AdminController(AdminService adminService) {
        this.adminService = adminService;
    }

    @GetMapping("/getAllAppointments")
    public ResponseEntity<List<AppointmentDto>> getAllAppointments() {
        return ResponseEntity.ok(adminService.getAllAppointments());
    }

    @GetMapping("/getAllRequests")
    public ResponseEntity<List<RequestDto>> getAllRequests() {
        return ResponseEntity.ok(adminService.getAllRequests());
    }

    @GetMapping("/getExpiredAppointments")
    public ResponseEntity<List<AppointmentDto>> getExpiredAppointments() {
        return ResponseEntity.ok(adminService.getExpiredAppointments());
    }

    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getDashboard() {
        Map<String, Object> dashboard = new HashMap<>();
        dashboard.put("totalAppointments", adminService.getTotalAppointments());
        dashboard.put("totalRequests", adminService.getTotalRequests());
        dashboard.put("expiredAppointments", adminService.getExpiredAppointments().size());
        dashboard.put("allAppointments", adminService.getAllAppointments());
        dashboard.put("allRequests", adminService.getAllRequests());
        return ResponseEntity.ok(dashboard);
    }
}
