package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Data
public class DeviceToken {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;
    
    private String token;
    
    // Link to User (if using User table)
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
    
    // CRITICAL: Store the user_id from Doctor/Patient/Admin
    // This ensures notification service has same ID as backend
    @Column(name = "backend_user_id", nullable = false)
    private Long backendUserId;
    
    // Device info
    private String deviceType;      // ANDROID, iOS, WEB
    private String deviceModel;
    private String osVersion;
    
    // Timestamp
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @PrePersist
    public void prePersist() {
        createdAt = LocalDateTime.now();
    }
}
