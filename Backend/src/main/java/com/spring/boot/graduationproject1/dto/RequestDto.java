package com.spring.boot.graduationproject1.dto;


import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

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
}
