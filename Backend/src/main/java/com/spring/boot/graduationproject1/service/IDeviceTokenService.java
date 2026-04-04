package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.DeviceTokenDto;
import com.spring.boot.graduationproject1.dto.RegisterDeviceTokenRequest;
import com.spring.boot.graduationproject1.model.DeviceToken;

import java.util.List;
import java.util.Optional;

/**
 * Interface for Device Token Service
 * Manages Firebase device tokens
 */
public interface IDeviceTokenService {
    
    /**
     * Register or update a device token
     * @param userId User ID
     * @param userType Type of user (PATIENT, DOCTOR)
     * @param request Registration request with token and device info
     * @return Registered DeviceTokenDto
     */
    DeviceTokenDto registerDeviceToken(Long userId, String userType, RegisterDeviceTokenRequest request);
    
    /**
     * Deactivate a device token (logout from device)
     * @param token FCM token to deactivate
     * @return True if successful, false if not found
     */
    Boolean deactivateDeviceToken(String token);
    
    /**
     * Get all active tokens for a user
     * @param userId User ID
     * @param userType Type of user
     * @return List of active DeviceTokenDtos
     */
    List<DeviceTokenDto> getActiveDeviceTokens(Long userId, String userType);
    
    /**
     * Get all tokens (active and inactive) for a user
     * @param userId User ID
     * @param userType Type of user
     * @return List of all DeviceTokenDtos
     */
    List<DeviceTokenDto> getAllDeviceTokens(Long userId, String userType);
    
    /**
     * Remove a specific device token by ID
     * @param tokenId Token ID
     * @return True if successful
     */
    Boolean removeDeviceToken(Long tokenId);
    
    /**
     * Check if token is active
     * @param token FCM token
     * @return True if active
     */
    Boolean isTokenActive(String token);
    
    /**
     * Get token details
     * @param token FCM token
     * @return Optional DeviceTokenDto
     */
    Optional<DeviceTokenDto> getTokenDetails(String token);
    
    /**
     * Count active tokens for user
     * @param userId User ID
     * @param userType Type of user
     * @return Number of active tokens
     */
    Long countActiveTokens(Long userId, String userType);
    
    /**
     * Clean up inactive tokens (soft delete)
     * @return Number of tokens cleaned up
     */
    Long cleanupInactiveTokens();
}
