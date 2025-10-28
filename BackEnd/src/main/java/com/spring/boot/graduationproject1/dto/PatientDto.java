package com.spring.boot.graduationproject1.dto;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PatientDto {
    private Long id;
    private String name;
    private String city;
    private String phoneNumber;
    private RoleDto role;
}
