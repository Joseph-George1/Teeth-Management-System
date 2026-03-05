package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.PatientDto;
import org.springframework.stereotype.Service;

@Service
public interface PatientService {
    PatientDto getPatientByDoctorId(long doctorId);
}
