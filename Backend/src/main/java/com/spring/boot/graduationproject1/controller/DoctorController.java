package com.spring.boot.graduationproject1.controller;


import com.spring.boot.graduationproject1.dto.DoctorDto;
import com.spring.boot.graduationproject1.dto.DoctorSummaryDto;
import com.spring.boot.graduationproject1.service.DoctorService;
import jakarta.transaction.SystemException;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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

    @GetMapping("/getDoctorById")
    public ResponseEntity<DoctorDto>getDoctorById(@RequestParam Long doctorId) throws SystemException {
        return ResponseEntity.ok().body(doctorService.getDoctorById(doctorId));
    }

    @PutMapping("updateDoctor")
    public ResponseEntity<DoctorDto>updateDoctor(@RequestBody @Valid DoctorDto doctorDto) throws SystemException {
        return ResponseEntity.ok().body(doctorService.updateDoctor(doctorDto));
    }
}
