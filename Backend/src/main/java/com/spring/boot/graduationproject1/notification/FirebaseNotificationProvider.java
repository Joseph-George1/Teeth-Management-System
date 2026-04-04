package com.spring.boot.graduationproject1.notification;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class FirebaseNotificationProvider implements NotificationProvider {
    private static final Logger logger = LoggerFactory.getLogger(FirebaseNotificationProvider.class);

    @Override
    public void send(String token, String title, String body) {
        try {
            Message message = Message.builder()
                    .setToken(token)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .build();

            String messageId = FirebaseMessaging.getInstance().send(message);
            logger.info("Notification sent successfully. Message ID: {}", messageId);
        } catch (Exception e) {
            logger.error("Failed to send notification to token: {}. Error: {}", token, e.getMessage(), e);
        }

    }
}
