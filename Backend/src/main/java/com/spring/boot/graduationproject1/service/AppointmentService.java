package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.AppointmentDto;
import com.spring.boot.graduationproject1.model.AppointmentStatus;

import java.util.List;

public interface AppointmentService {
    AppointmentDto createAppointment(Long requestId, AppointmentDto appointmentDto);
    List<AppointmentDto> getPendingAppointmentsForDoctor();
    AppointmentDto updateAppointmentStatus(Long appointmentId, AppointmentStatus status);
    List<AppointmentDto> getAppointmentHistory(Long doctorId);
    void cancelExpiredAppointments();
    void deleteAppointment(Long appointmentId);
    List<AppointmentDto> getApprovedAndDoneAppointments();
    List<AppointmentDto> getApprovedAppointments();
    List<AppointmentDto> getDoneAppointments();
    List<AppointmentDto> getCancelledAppointments();
}
