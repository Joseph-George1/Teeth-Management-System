package com.spring.boot.graduationproject1.repo;

import com.spring.boot.graduationproject1.model.DeviceToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

/**
 * Repository for DeviceToken entity
 * Handles database operations for Firebase device tokens
 */
public interface DeviceTokenRepo extends JpaRepository<DeviceToken, Long> {
    
    /**
     * Find device token by FCM token string
     */
    Optional<DeviceToken> findByToken(String token);
    
    /**
     * Find all active tokens for a user
     */
    List<DeviceToken> findByUserIdAndUserTypeAndIsActiveTrue(
        Long userId, 
        DeviceToken.UserType userType
    );
    
    /**
     * Find all tokens (active and inactive) for a user
     */
    List<DeviceToken> findByUserIdAndUserType(
        Long userId, 
        DeviceToken.UserType userType
    );
    
    /**
     * Find all active tokens for a user by platform
     */
    List<DeviceToken> findByUserIdAndUserTypeAndPlatformAndIsActiveTrue(
        Long userId,
        DeviceToken.UserType userType,
        DeviceToken.DevicePlatform platform
    );
    
    /**
     * Count active tokens for a user
     */
    Long countByUserIdAndUserTypeAndIsActiveTrue(
        Long userId,
        DeviceToken.UserType userType
    );
    
    /**
     * Check if token exists and is active
     */
    Boolean existsByTokenAndIsActiveTrue(String token);
    
    /**
     * Find tokens by device name for a user
     */
    List<DeviceToken> findByUserIdAndUserTypeAndDeviceNameContaining(
        Long userId,
        DeviceToken.UserType userType,
        String deviceName
    );
}
