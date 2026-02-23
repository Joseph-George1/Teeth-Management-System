package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.AppointmentDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface AppointmentService {
    List<AppointmentDto>getAllAppointments();
    AppointmentDto getAppointmentById(Long id);
    AppointmentDto createAppointment(AppointmentDto appointmentDto);
}
