package com.spring.boot.graduationproject1.controller;


import com.spring.boot.graduationproject1.dto.DoctorSummaryDto;
import com.spring.boot.graduationproject1.service.DoctorService;
import jakarta.transaction.SystemException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/doctor")
public class DoctorController {

    private final DoctorService doctorService;

    public DoctorController(DoctorService doctorService){
        this.doctorService=doctorService;
    }

    @GetMapping("/getDoctors")
    public ResponseEntity<List<DoctorSummaryDto>> getDoctor(){
        return ResponseEntity.ok().body(doctorService.getDoctors());
    }

    @GetMapping("/getDoctorsByCity")
    public ResponseEntity<List<DoctorSummaryDto>> getDoctorByCityId(@RequestParam Long cityId ) throws SystemException {
        return ResponseEntity.ok().body(doctorService.getDoctorsByCityId(cityId));
    }

    @GetMapping("/getDoctorsByCategory")
    public ResponseEntity<List<DoctorSummaryDto>> getDoctorByCategoryId(@RequestParam Long categoryId ) throws SystemException {
        return ResponseEntity.ok().body(doctorService.getDoctorByCategoryId(categoryId));
    }
}
