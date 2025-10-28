package com.spring.boot.graduationproject1.controller;

import com.spring.boot.graduationproject1.dto.PatientDto;
import com.spring.boot.graduationproject1.services.PatientService;
import jakarta.transaction.SystemException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/patient")
public class PatientController {

    private final PatientService patientService;

    public PatientController(PatientService patientService) {
        this.patientService = patientService;
    }

    @PostMapping("/signup")
    public ResponseEntity<PatientDto> signUp(@RequestBody PatientDto patientDto) throws SystemException {
        return ResponseEntity.ok().body(patientService.signUp(patientDto));
    }

    @PostMapping("/login")
    public ResponseEntity<PatientDto> login(@RequestBody PatientDto patientDto) {
        return ResponseEntity.ok().body(patientService.login(patientDto));
    }
}
