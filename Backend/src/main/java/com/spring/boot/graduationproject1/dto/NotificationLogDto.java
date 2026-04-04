package com.spring.boot.graduationproject1.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * DTO for NotificationLog
 * Used for API responses
 */
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class NotificationLogDto {
    
    private Long id;
    private String title;
    private String body;
    private String notificationType;  // APPOINTMENT_CONFIRMED, etc.
    private String deliveryStatus;    // SENT, DELIVERED, FAILED
    private Boolean isRead;
    private LocalDateTime sentAt;
    private Long relatedEntityId;     // Appointment ID, etc.
    private String relatedEntityType; // APPOINTMENT, REQUEST, etc.
}
