package com.spring.boot.graduationproject1.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class RequestDto {


    private String doctorFirstName;
    private String doctorLastName;
    private String doctorPhoneNumber;
    private String doctorCityName;
    private String doctorUniversityName;


    private String categoryName;


    private String description;
    private LocalDateTime dateTime;
}