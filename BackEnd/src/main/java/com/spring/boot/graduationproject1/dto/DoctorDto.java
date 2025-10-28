package com.spring.boot.graduationproject1.dto;

import jakarta.persistence.Column;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class DoctorDto {
    private Long id;
    private String name;
    private String uniName;
    private String studyYear;
    private String city;
    private String email;
    private String password;
    private RoleDto role;
}
