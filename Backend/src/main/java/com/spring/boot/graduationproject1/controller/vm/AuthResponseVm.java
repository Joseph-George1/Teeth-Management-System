package com.spring.boot.graduationproject1.controller.vm;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
public class AuthResponseVm {
    private String token;
    private Long userId;
    private String email;
    private String userType;  // DOCTOR, PATIENT, ADMIN
    
    // Constructor for backwards compatibility
    public AuthResponseVm(String token) {
        this.token = token;
    }
}
