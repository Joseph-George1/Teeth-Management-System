/*
 * Copyright (c) 2026 Muhammad Ashraf Tawfik Elkateb
 * GitHub: https://github.com/MuhammamdElKateb
 */
package com.spring.boot.graduationproject1.dto;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class DoctorRepresentDto {
    private String firstName;
    private String lastName;
    private String studyYear;
    private String phoneNumber;
    private String universityName;
    private String cityName;
    private String categoryName;
    private String email;
}
