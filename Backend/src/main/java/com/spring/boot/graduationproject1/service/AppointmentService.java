package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.AppointmentDto;

import java.util.List;

public interface AppointmentService {
    List<AppointmentDto>getAllAppointments();
    AppointmentDto getAppointmentById(Long id);
    AppointmentDto createAppointment(AppointmentDto appointmentDto);
    List<AppointmentDto>getAppointmentsByDoctorId();


}
