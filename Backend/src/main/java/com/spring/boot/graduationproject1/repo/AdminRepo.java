package com.spring.boot.graduationproject1.repo;

import com.spring.boot.graduationproject1.model.Admin;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AdminRepo extends JpaRepository<Admin, Long> {
    Optional<Admin>findByEmail(String email);
}
