package com.spring.boot.graduationproject1.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Request DTO for registering a device token
 */
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class RegisterDeviceTokenRequest {
    
    /**
     * FCM device token from Firebase SDK on client
     */
    private String token;
    
    /**
     * Device platform: ANDROID, IOS, WEB
     */
    private String platform;
    
    /**
     * Optional device name for user reference
     * e.g., "My iPhone 13", "Office Computer"
     */
    private String deviceName;
}
