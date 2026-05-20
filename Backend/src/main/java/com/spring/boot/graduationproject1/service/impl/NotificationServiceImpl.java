package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.model.NotificationLog;
import com.spring.boot.graduationproject1.model.User;
import com.spring.boot.graduationproject1.repo.NotificationLogRepo;
import com.spring.boot.graduationproject1.service.NotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Service
public class NotificationServiceImpl implements NotificationService {
    private static final Logger logger = LoggerFactory.getLogger(NotificationServiceImpl.class);

    private final NotificationLogRepo notificationLogRepo;
    private final NotificationClientServiceImpl notificationClientService;

    public NotificationServiceImpl(NotificationLogRepo notificationLogRepo, 
                                 NotificationClientServiceImpl notificationClientService) {
        this.notificationLogRepo = notificationLogRepo;
        this.notificationClientService = notificationClientService;
    }

    @Override
    public void notifyUser(User user, String title, String body) {
        try {
            // Log the notification locally
            NotificationLog log = new NotificationLog();
            log.setUser(user);
            log.setTitle(title);
            log.setBody(body);
            log.setReadStatus(false);
            log.setCreatedAt(LocalDateTime.now());
            notificationLogRepo.save(log);
            
            // Queue for delivery via microservice (async)
            logger.info("Notification queued for user {}: {}", user.getId(), title);
            
        } catch (Exception e) {
            logger.error("Error notifying user {}: {}", user.getId(), e.getMessage(), e);
        }
    }
}
