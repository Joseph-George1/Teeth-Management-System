package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.AdminDto;
import com.spring.boot.graduationproject1.dto.AppointmentDto;
import com.spring.boot.graduationproject1.dto.RequestDto;

import java.util.List;

public interface AdminService {
    AdminDto getAdminsByEmail(String email);
    List<AppointmentDto> getAllAppointments();
    List<RequestDto> getAllRequests();
    List<AppointmentDto> getExpiredAppointments();
    Long getTotalAppointments();
    Long getTotalRequests();
}
