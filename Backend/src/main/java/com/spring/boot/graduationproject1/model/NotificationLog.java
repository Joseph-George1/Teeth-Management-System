package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class NotificationLog {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;
    private String title;
    private String body;
    private boolean readStatus;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
}
