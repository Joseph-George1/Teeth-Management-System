package com.spring.boot.graduationproject1.repo;


import com.spring.boot.graduationproject1.model.Category;
import com.spring.boot.graduationproject1.model.Doctor;
import com.spring.boot.graduationproject1.model.Requests;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RequestRepo extends JpaRepository<Requests, Long> {
   Optional<Requests> findByDoctorIdAndCategoryId(Long doctorId, Long categoryId);
   List<Requests> findByDoctor(Doctor doctor);
   List<Requests> findByCategoryId(Long categoryId);
   void deleteByDoctor(Doctor doctor);
   Long countByStatus(String status);
   Optional<Requests> findByIdAndDoctor(Long id, Doctor doctor);
}
