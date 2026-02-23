package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.dto.AppointmentDto;
import com.spring.boot.graduationproject1.service.AppointmentService;

import java.util.List;

public class AppointmentServiceImpl implements AppointmentService {
    @Override
    public List<AppointmentDto> getAllAppointments() {
        return List.of();
    }

    @Override
    public AppointmentDto getAppointmentById(Long id) {
        return null;
    }

    @Override
    public AppointmentDto createAppointment(AppointmentDto appointmentDto) {
        return null;
    }
}
