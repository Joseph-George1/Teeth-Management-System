package com.spring.boot.graduationproject1.repo;

import com.spring.boot.graduationproject1.model.DeviceToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DeviceTokenRepo extends JpaRepository<DeviceToken, Long> {
    List<DeviceToken> findByUserId(Long userId);
}
