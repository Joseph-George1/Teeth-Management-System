package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.model.DeviceToken;
import com.spring.boot.graduationproject1.model.NotificationLog;
import com.spring.boot.graduationproject1.model.User;
import com.spring.boot.graduationproject1.notification.NotificationProvider;
import com.spring.boot.graduationproject1.repo.NotificationLogRepo;
import com.spring.boot.graduationproject1.service.DeviceTokenService;
import com.spring.boot.graduationproject1.service.NotificationService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class NotificationServiceImpl implements NotificationService {

    private final NotificationLogRepo notificationLogRepo;
    private final DeviceTokenService deviceTokenService;
    private final NotificationProvider notificationProvider;

    public NotificationServiceImpl(NotificationLogRepo notificationLogRepo, DeviceTokenService deviceTokenService, NotificationProvider notificationProvider) {
        this.notificationLogRepo = notificationLogRepo;
        this.deviceTokenService = deviceTokenService;
        this.notificationProvider = notificationProvider;
    }


    @Override
    public void notifyUser(User user, String title, String body) {


        List<String> tokens = deviceTokenService.getUserTokens(user.getId());

        for (String token : tokens) {
            notificationProvider.send(token, title, body);
        }

        NotificationLog log = new NotificationLog();
        log.setUser(user);
        log.setTitle(title);
        log.setBody(body);
        log.setReadStatus(false);

        notificationLogRepo.save(log);

    }
}
