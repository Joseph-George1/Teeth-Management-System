package com.spring.boot.graduationproject1.dto;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class PatientDto {
    private long id;
    private String firstName;
    private String lastName;
    private String surName;
    private String phoneNumber;
    private String cityName;
    private long roleId;
}
