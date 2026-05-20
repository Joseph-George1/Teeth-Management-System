package com.spring.boot.graduationproject1.controller;

import com.spring.boot.graduationproject1.dto.UniversityDto;
import com.spring.boot.graduationproject1.service.UniversityService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/university")
public class UniversityController {

    private final UniversityService universityService;

    public UniversityController(UniversityService universityService) {
        this.universityService = universityService;
    }


    @GetMapping("/getAllUniversities")
    public ResponseEntity<List<UniversityDto>> getUniversities(){
        return ResponseEntity.ok().body(universityService.getUniversities());
    }
}
