package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.PatientDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface PatientService {
    List<PatientDto> getPatientByDoctorId();
}
