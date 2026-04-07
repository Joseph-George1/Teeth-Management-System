package com.spring.boot.graduationproject1.notification;

public interface NotificationProvider {
    void send(String token, String title, String body);

}
