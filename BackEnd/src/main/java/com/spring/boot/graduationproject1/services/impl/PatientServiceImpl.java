package com.spring.boot.graduationproject1.services.impl;

import com.spring.boot.graduationproject1.dto.PatientDto;
import com.spring.boot.graduationproject1.mapper.PatientMapper;
import com.spring.boot.graduationproject1.model.Patient;
import com.spring.boot.graduationproject1.model.Role;
import com.spring.boot.graduationproject1.repo.PatientRepo;
import com.spring.boot.graduationproject1.repo.RoleRepo;
import com.spring.boot.graduationproject1.services.PatientService;
import jakarta.transaction.SystemException;
import org.springframework.stereotype.Service;

@Service
public class PatientServiceImpl implements PatientService {

    private final PatientMapper patientMapper;
    private final PatientRepo patientRepo;
    private final RoleRepo roleRepo;

    public PatientServiceImpl( PatientMapper patientMapper, PatientRepo patientRepo, RoleRepo roleRepo) {
        this.patientMapper = patientMapper;
        this.patientRepo = patientRepo;
        this.roleRepo = roleRepo;
    }


    @Override
    public PatientDto signUp(PatientDto patientDto) throws SystemException {
        // Validate input
        if (patientDto == null || patientDto.getPhoneNumber() == null) {
            throw new IllegalArgumentException("Patient data cannot be null");
        }

        // Check if phone number already exists
        if (patientRepo.findByPhoneNumber(patientDto.getPhoneNumber()).isPresent()) {
            throw new IllegalArgumentException("Patient with phone number " + patientDto.getPhoneNumber() + " already exists");
        }

        // Find or create the “PATIENT” role
        Role patientRole = roleRepo.findByName("ROLE_PATIENT")
                .orElseThrow(()->new SystemException("ROLE_PATIENT NOT FOUND"));

        // Convert DTO → Entity
        Patient patient = patientMapper.toEntity(patientDto);

        // Assign the role
        patient.setRole(patientRole);

        // Save to DB
        patient = patientRepo.save(patient);

        // Convert back Entity → DTO
        return patientMapper.toDto(patient);
    }


    @Override
    public PatientDto login(PatientDto patientDto) {
        // Validate phone number input
        if (patientDto.getPhoneNumber() == null) {
            throw new IllegalArgumentException("Phone number is required");
        }

        // Find patient by phone number
        Patient patient = patientRepo.findByPhoneNumber(patientDto.getPhoneNumber())
                .orElseThrow(() -> new IllegalArgumentException("Patient not found"));

        // Convert Entity → DTO and return
        return patientMapper.toDto(patient);
    }
}
