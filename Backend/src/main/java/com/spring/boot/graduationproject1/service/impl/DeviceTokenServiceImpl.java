package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.model.DeviceToken;
import com.spring.boot.graduationproject1.model.User;
import com.spring.boot.graduationproject1.repo.DeviceTokenRepo;
import com.spring.boot.graduationproject1.service.DeviceTokenService;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@Primary
public class DeviceTokenServiceImpl implements DeviceTokenService {

    private final DeviceTokenRepo deviceTokenRepo;

    public  DeviceTokenServiceImpl(DeviceTokenRepo deviceTokenRepo) {
        this.deviceTokenRepo = deviceTokenRepo;
    }

    @Override
    public void saveToken(User user, String token) {
        DeviceToken dt = new DeviceToken();
        dt.setUser(user);
        dt.setToken(token);
        deviceTokenRepo.save(dt);


    }

    @Override
    public List<String> getUserTokens(Long userId) {
        return deviceTokenRepo.findByUserId(userId)
                .stream()
                .map(DeviceToken::getToken)
                .toList();

    }
}
