package com.spring.boot.graduationproject1.dto;


import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class RequestDto {
    private Long id;

    private Long doctorId;
    private String doctorName;  // firstName + lastName

    private Long categoryId;
    private String categoryName;
    private String description;
    private LocalDateTime dateTime;
}
