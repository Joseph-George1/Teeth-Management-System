package com.spring.boot.graduationproject1.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class SignUpRequest {
    @NotBlank(message = "doctor.firstname.required")
    private String firstName;
    @NotBlank(message = "doctor.lastname.required")
    private String lastName;
    @Email(message = "doctor.email.invalid")
    @NotBlank(message = "doctor.email.required")
    private String email;
    @NotBlank(message = "doctor.password.required")
    private String password;
    @NotBlank(message = "doctor.phonenumber.required")
    private String phoneNumber;
    @NotBlank(message = "doctor.city.required")
    private String cityName;
    @NotBlank(message = "doctor.studyyear.required")
    private String studyYear;
    @NotBlank(message = "doctor.category.required")
    private String categoryName;
    @NotBlank(message = "doctor.university.required")
    private String universityName;


}
