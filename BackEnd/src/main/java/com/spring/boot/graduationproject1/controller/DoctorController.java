package com.spring.boot.graduationproject1.controller;

import com.spring.boot.graduationproject1.dto.DoctorDto;
import com.spring.boot.graduationproject1.services.DoctorServices;
import jakarta.transaction.SystemException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/doctor")
public class DoctorController {


    private final DoctorServices doctorServices;

    public DoctorController(DoctorServices doctorServices) {
        this.doctorServices = doctorServices;
    }

    @PostMapping("/signup")
    public ResponseEntity<DoctorDto> signUp(@RequestBody DoctorDto doctorDto) throws SystemException {
        return ResponseEntity.ok().body(doctorServices.signUp(doctorDto));
    }

    @PostMapping("/login")
    public ResponseEntity<DoctorDto> login(@RequestBody DoctorDto doctorDto) {
        return ResponseEntity.ok().body(doctorServices.login(doctorDto));
    }

}
