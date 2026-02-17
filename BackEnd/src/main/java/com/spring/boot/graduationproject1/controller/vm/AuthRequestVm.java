package com.spring.boot.graduationproject1.controller.vm;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter
@Setter
public class AuthRequestVm {
    @Email(message = "doctor.email.invalid")
    @NotBlank(message = "doctor.email.required")
    private String email;
    @NotBlank(message = "doctor.password.required")
    private String password;
}
