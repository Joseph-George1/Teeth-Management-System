package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.dto.AppointmentDto;
import com.spring.boot.graduationproject1.mapper.AppointmentMapper;
import com.spring.boot.graduationproject1.model.Appointments;
import com.spring.boot.graduationproject1.model.Doctor;
import com.spring.boot.graduationproject1.repo.AppointmentRepo;
import com.spring.boot.graduationproject1.repo.CityRepo;
import com.spring.boot.graduationproject1.repo.DoctorRepo;
import com.spring.boot.graduationproject1.repo.PatientRepo;
import com.spring.boot.graduationproject1.service.AppointmentService;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AppointmentServiceImpl implements AppointmentService {

    private final AppointmentRepo appointmentRepo;
    private final AppointmentMapper appointmentMapper;
    private final CityRepo cityRepo;
    private final DoctorRepo doctorRepo;
    private final PatientRepo patientRepo;

    public AppointmentServiceImpl(AppointmentRepo appointmentRepo, AppointmentMapper appointmentMapper,
                                  CityRepo cityRepo, DoctorRepo doctorRepo, PatientRepo patientRepo) {
        this.appointmentMapper = appointmentMapper;
        this.appointmentRepo = appointmentRepo;
        this.cityRepo = cityRepo;
        this.doctorRepo = doctorRepo;
        this.patientRepo = patientRepo;
    }

    @Override
    public List<AppointmentDto> getAllAppointments() {
        return appointmentMapper.toListDto(appointmentRepo.findAll());
    }

    @Override
    public AppointmentDto getAppointmentById(Long id) {
        return null;
    }

    @Override
    public AppointmentDto createAppointment(AppointmentDto appointmentDto) {
        return null;
    }

    @Override
    public List<AppointmentDto> getAppointmentsByDoctorId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        Doctor doctor = doctorRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));

        List<Appointments> appointments = appointmentRepo.findByDoctorId(doctor.getId());

        return appointmentMapper.toListDto(appointments);
    }
}
