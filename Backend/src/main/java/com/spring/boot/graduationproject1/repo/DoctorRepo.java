package com.spring.boot.graduationproject1.repo;

import com.spring.boot.graduationproject1.model.Category;
import com.spring.boot.graduationproject1.model.City;
import com.spring.boot.graduationproject1.model.Doctor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface DoctorRepo extends JpaRepository<Doctor, Long> {
    Optional<Doctor>findByEmail(String email);
    List<Doctor>findByCity(City city);
    List<Doctor>findByCategory(Category category);

    @Query("SELECT COUNT(DISTINCT d.university) FROM Doctor d")
    Long countDistinctUniversities();
}
