package com.spring.boot.graduationproject1.services.impl;

import com.spring.boot.graduationproject1.dto.DoctorDto;
import com.spring.boot.graduationproject1.dto.RoleDto;
import com.spring.boot.graduationproject1.mapper.DoctorMapper;
import com.spring.boot.graduationproject1.model.Doctor;
import com.spring.boot.graduationproject1.model.Role;
import com.spring.boot.graduationproject1.repo.DoctorRepo;
import com.spring.boot.graduationproject1.repo.RoleRepo;
import com.spring.boot.graduationproject1.services.DoctorServices;
import jakarta.transaction.SystemException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;



@Service
public class DoctorServiceImpl implements DoctorServices {
    private final DoctorRepo doctorRepo;
    private final RoleRepo roleRepo;
    private final DoctorMapper doctorMapper;
    private final PasswordEncoder passwordEncoder;

    public DoctorServiceImpl(DoctorRepo doctorRepo,RoleRepo roleRepo, DoctorMapper doctorMapper,PasswordEncoder passwordEncoder) {
        this.doctorRepo = doctorRepo;
        this.roleRepo = roleRepo;
        this.doctorMapper = doctorMapper;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public DoctorDto signUp(DoctorDto doctorDto) throws SystemException {

        // Validate required fields
        if (doctorDto == null || doctorDto.getEmail() == null) {
            throw new IllegalArgumentException("Doctor data cannot be null");
        }

        // Check if email is already registered
        if (doctorRepo.findByEmail(doctorDto.getEmail()).isPresent()) {
            throw new SystemException("Email already registered");
        }

        // Fetch role "DOCTOR" or create it if it doesn't exist
        Role doctorRole = roleRepo.findByName("ROLE_DOCTOR")
                .orElseThrow(()->new SystemException("ROLE_DOCTOR NOT FOUND"));

        // Convert DTO → Entity using MapStruct
        Doctor doctor = doctorMapper.toEntity(doctorDto);

        // Assign role to doctor
        doctor.setRole(doctorRole);

        // Hash password before saving for security
        String hashedPassword = passwordEncoder.encode(doctorDto.getPassword());
        doctor.setPassword(hashedPassword);

        // Save to database
        doctor = doctorRepo.save(doctor);

        // Convert Entity → DTO before returning
        return doctorMapper.toDto(doctor);
    }

    @Override
    public DoctorDto login(DoctorDto doctorDto) {

        // Validate login credentials
        if (doctorDto == null || doctorDto.getEmail() == null || doctorDto.getPassword() == null) {
            throw new IllegalArgumentException("Email and password are required");
        }

        // Find doctor by email
        Doctor doctor = doctorRepo.findByEmail(doctorDto.getEmail())
                .orElseThrow(() -> new SecurityException("Invalid email or password"));

        // Compare hashed password with input password
        if (!passwordEncoder.matches(doctorDto.getPassword(), doctor.getPassword())) {
            throw new SecurityException("Invalid email or password");
        }

        // Convert Entity → DTO
        DoctorDto authenticatedDoctor = doctorMapper.toDto(doctor);

        // Never return password in response
        authenticatedDoctor.setPassword(null);

        return authenticatedDoctor;
    }
}