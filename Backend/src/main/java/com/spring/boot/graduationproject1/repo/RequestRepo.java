package com.spring.boot.graduationproject1.repo;


import com.spring.boot.graduationproject1.model.Doctor;
import com.spring.boot.graduationproject1.model.Requests;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RequestRepo extends JpaRepository<Requests, Long> {
   Optional<Requests> findByDoctorIdAndCategoryId(Long doctorId, Long categoryId);
   Optional<Requests> findByDoctor(Doctor doctor);
}
