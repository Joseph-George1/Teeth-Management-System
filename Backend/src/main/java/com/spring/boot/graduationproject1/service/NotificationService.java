package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.model.User;
import org.springframework.stereotype.Service;

@Service
public interface NotificationService {
    public void notifyUser(User user, String title, String body);
}
