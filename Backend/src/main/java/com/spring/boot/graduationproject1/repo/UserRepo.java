package com.spring.boot.graduationproject1.repo;

import com.spring.boot.graduationproject1.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepo extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
}

