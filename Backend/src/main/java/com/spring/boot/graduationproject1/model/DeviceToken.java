package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class DeviceToken {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;
    private String token;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
}
