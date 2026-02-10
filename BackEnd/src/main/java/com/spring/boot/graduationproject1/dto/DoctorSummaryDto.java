package com.spring.boot.graduationproject1.dto;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class DoctorSummaryDto {

    private String firstName;
    private String lastName;
    private String studyYear;
    private String phoneNumber;
    private String universityName;
    private String cityName;
    private String categoryName;
}
