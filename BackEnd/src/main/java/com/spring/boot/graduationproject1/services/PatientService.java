package com.spring.boot.graduationproject1.services;

import com.spring.boot.graduationproject1.dto.PatientDto;
import jakarta.transaction.SystemException;
import org.springframework.stereotype.Service;

@Service
public interface PatientService {
    PatientDto signUp(PatientDto patientDto) throws SystemException;
    PatientDto login(PatientDto patientDto);
}
