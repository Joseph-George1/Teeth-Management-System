package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.model.User;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface DeviceTokenService {
    public void saveToken(User user, String token);
    public List<String> getUserTokens(Long userId);
}
