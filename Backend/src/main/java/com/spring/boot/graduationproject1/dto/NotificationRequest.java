package com.spring.boot.graduationproject1.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotificationRequest {
    private Long appointmentId;
    private Long patientId;
    private Long doctorId;
    private String idempotencyKey;
    private String title;
    private String body;
    private String type;
    private String payload;
}
