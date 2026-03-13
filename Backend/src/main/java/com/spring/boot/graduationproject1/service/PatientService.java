package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.PatientDto;

public interface PatientService {
    PatientDto getPatientByDoctorId(long doctorId);
}
