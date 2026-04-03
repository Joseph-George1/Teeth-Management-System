package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.Data;

import java.util.List;

@Entity
@Data
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;
    private String name;
    private String email;

    @OneToMany(mappedBy = "user")
    private List<DeviceToken> deviceTokens;

    @OneToMany(mappedBy = "user")
    private List<NotificationLog> notificationLogs;
}
