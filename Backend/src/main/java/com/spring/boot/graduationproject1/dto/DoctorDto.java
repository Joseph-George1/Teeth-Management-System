package com.spring.boot.graduationproject1.dto;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class DoctorDto {
    private Long id;
    private String categoryName;
    private String universityName;
    private String firstName;
    private String lastName;
    private String email;
    private String studyYear;
    private String password;
    private String phoneNumber;
    private String cityName;
}
