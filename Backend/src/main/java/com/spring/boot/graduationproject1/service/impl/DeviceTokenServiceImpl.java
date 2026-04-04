package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.dto.DeviceTokenDto;
import com.spring.boot.graduationproject1.dto.RegisterDeviceTokenRequest;
import com.spring.boot.graduationproject1.mapper.DeviceTokenMapper;
import com.spring.boot.graduationproject1.model.DeviceToken;
import com.spring.boot.graduationproject1.repo.DeviceTokenRepo;
import com.spring.boot.graduationproject1.service.IDeviceTokenService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class DeviceTokenServiceImpl implements IDeviceTokenService {
    
    private final DeviceTokenRepo deviceTokenRepo;
    private final DeviceTokenMapper deviceTokenMapper;
    
    public DeviceTokenServiceImpl(DeviceTokenRepo deviceTokenRepo, DeviceTokenMapper deviceTokenMapper) {
        this.deviceTokenRepo = deviceTokenRepo;
        this.deviceTokenMapper = deviceTokenMapper;
    }
    
    @Override
    public DeviceTokenDto registerDeviceToken(Long userId, String userType, RegisterDeviceTokenRequest request) {
        // Check if token already exists and is active
        Optional<DeviceToken> existingToken = deviceTokenRepo.findByToken(request.getToken());
        
        DeviceToken deviceToken;
        if (existingToken.isPresent()) {
            // Update existing token
            deviceToken = existingToken.get();
            deviceToken.setIsActive(true);
            deviceToken.setLastUsedAt(LocalDateTime.now());
            deviceToken.setDeactivatedAt(null);
        } else {
            // Create new token
            deviceToken = new DeviceToken();
            deviceToken.setToken(request.getToken());
            deviceToken.setUserId(userId);
            deviceToken.setUserType(DeviceToken.UserType.valueOf(userType.toUpperCase()));
            deviceToken.setPlatform(DeviceToken.DevicePlatform.valueOf(request.getPlatform().toUpperCase()));
            deviceToken.setDeviceName(request.getDeviceName());
            deviceToken.setIsActive(true);
            deviceToken.setRegisteredAt(LocalDateTime.now());
            deviceToken.setLastUsedAt(LocalDateTime.now());
        }
        
        deviceTokenRepo.save(deviceToken);
        return deviceTokenMapper.toDto(deviceToken);
    }
    
    @Override
    public Boolean deactivateDeviceToken(String token) {
        Optional<DeviceToken> deviceToken = deviceTokenRepo.findByToken(token);
        
        if (deviceToken.isPresent()) {
            DeviceToken dt = deviceToken.get();
            dt.setIsActive(false);
            dt.setDeactivatedAt(LocalDateTime.now());
            deviceTokenRepo.save(dt);
            return true;
        }
        return false;
    }
    
    @Override
    public List<DeviceTokenDto> getActiveDeviceTokens(Long userId, String userType) {
        return deviceTokenRepo.findByUserIdAndUserTypeAndIsActiveTrue(
            userId,
            DeviceToken.UserType.valueOf(userType.toUpperCase())
        ).stream()
         .map(deviceTokenMapper::toDto)
         .collect(Collectors.toList());
    }
    
    @Override
    public List<DeviceTokenDto> getAllDeviceTokens(Long userId, String userType) {
        return deviceTokenRepo.findByUserIdAndUserType(
            userId,
            DeviceToken.UserType.valueOf(userType.toUpperCase())
        ).stream()
         .map(deviceTokenMapper::toDto)
         .collect(Collectors.toList());
    }
    
    @Override
    public Boolean removeDeviceToken(Long tokenId) {
        if (deviceTokenRepo.existsById(tokenId)) {
            deviceTokenRepo.deleteById(tokenId);
            return true;
        }
        return false;
    }
    
    @Override
    public Boolean isTokenActive(String token) {
        return deviceTokenRepo.existsByTokenAndIsActiveTrue(token);
    }
    
    @Override
    public Optional<DeviceTokenDto> getTokenDetails(String token) {
        return deviceTokenRepo.findByToken(token)
            .map(deviceTokenMapper::toDto);
    }
    
    @Override
    public Long countActiveTokens(Long userId, String userType) {
        return deviceTokenRepo.countByUserIdAndUserTypeAndIsActiveTrue(
            userId,
            DeviceToken.UserType.valueOf(userType.toUpperCase())
        );
    }
    
    @Override
    public Long cleanupInactiveTokens() {
        // Find all inactive tokens
        List<DeviceToken> allTokens = deviceTokenRepo.findAll();
        long cleanedCount = 0;
        
        for (DeviceToken token : allTokens) {
            if (!token.getIsActive() && token.getDeactivatedAt() != null) {
                // Remove tokens inactive for more than 30 days
                if (LocalDateTime.now().minusDays(30).isAfter(token.getDeactivatedAt())) {
                    deviceTokenRepo.delete(token);
                    cleanedCount++;
                }
            }
        }
        
        return cleanedCount;
    }
}
