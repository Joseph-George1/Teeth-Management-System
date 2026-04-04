package com.spring.boot.graduationproject1.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * DTO for DeviceToken
 * Used for API requests/responses
 */
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class DeviceTokenDto {
    
    private Long id;
    private String token;
    private Long userId;
    private String userType;  // PATIENT, DOCTOR, ADMIN
    private String platform;  // ANDROID, IOS, WEB
    private String deviceName;
    private Boolean isActive;
    private LocalDateTime registeredAt;
    private LocalDateTime lastUsedAt;
}
