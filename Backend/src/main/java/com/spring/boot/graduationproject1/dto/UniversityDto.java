package com.spring.boot.graduationproject1.dto;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class UniversityDto {
    private long id;
    private String name;
    private String city;
    private String location;
    private String longitude;
    private String latitude;


}
