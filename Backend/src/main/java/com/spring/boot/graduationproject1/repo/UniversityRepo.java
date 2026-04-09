package com.spring.boot.graduationproject1.repo;

import com.spring.boot.graduationproject1.model.University;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UniversityRepo extends JpaRepository<University, Long> {
    Optional<University> findByName(String name);
}
