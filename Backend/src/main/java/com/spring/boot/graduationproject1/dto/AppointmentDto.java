package com.spring.boot.graduationproject1.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class AppointmentDto {
    private Long id;

    private Long doctorId;
    private String doctorFirstName;
    private String doctorLastName;

    private Long patientId;
    private String patientFirstName;
    private String patientLastName;
}
