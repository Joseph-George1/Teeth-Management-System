package com.spring.boot.graduationproject1.repo;

import com.spring.boot.graduationproject1.model.Patients;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;


public interface PatientRepo extends JpaRepository<Patients, Long> {
    Optional<Patients> findByPhoneNumber(String phoneNumber);
    List<Patients> findDistinctByAppointmentsDoctorId(Long doctorId);
}
