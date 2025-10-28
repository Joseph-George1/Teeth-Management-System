package com.spring.boot.graduationproject1.repo;

import com.spring.boot.graduationproject1.model.Patient;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;


public interface PatientRepo extends JpaRepository<Patient, Long> {
    Optional<Patient> findByPhoneNumber(String phoneNumber);
}
