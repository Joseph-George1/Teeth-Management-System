package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.dto.AppointmentDto;
import com.spring.boot.graduationproject1.dto.DoctorDto;
import com.spring.boot.graduationproject1.mapper.AppointmentMapper;
import com.spring.boot.graduationproject1.model.Appointments;
import com.spring.boot.graduationproject1.model.Doctor;
import com.spring.boot.graduationproject1.model.Patients;
import com.spring.boot.graduationproject1.model.Role;
import com.spring.boot.graduationproject1.repo.*;
import com.spring.boot.graduationproject1.service.AppointmentService;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class AppointmentServiceImpl implements AppointmentService {

    private final AppointmentRepo appointmentRepo;
    private final AppointmentMapper appointmentMapper;
    private final CityRepo cityRepo;
    private final DoctorRepo doctorRepo;
    private final PatientRepo patientRepo;
    private final RoleRepo roleRepo;

    public AppointmentServiceImpl(AppointmentRepo appointmentRepo, AppointmentMapper appointmentMapper,
                                  CityRepo cityRepo, DoctorRepo doctorRepo, PatientRepo patientRepo,RoleRepo roleRepo) {
        this.appointmentMapper = appointmentMapper;
        this.appointmentRepo = appointmentRepo;
        this.cityRepo = cityRepo;
        this.doctorRepo = doctorRepo;
        this.patientRepo = patientRepo;
        this.roleRepo = roleRepo;
    }

    @Override
    public List<AppointmentDto> getAllAppointments() {
        return appointmentMapper.toListDto(appointmentRepo.findAll());
    }

    @Override
    public AppointmentDto getAppointmentById(Long id) {
        Optional<Appointments> appointments = appointmentRepo.findById(id);
        if(appointments.isEmpty()){
            throw new RuntimeException("Appointment not found");
        }
        return appointmentMapper.toDto(appointments.get());
    }

    @Override
    public AppointmentDto createAppointment(AppointmentDto appointmentDto) {
        Doctor doctor = doctorRepo.findById(appointmentDto.getDoctorId())
                .orElseThrow(() -> new RuntimeException("Doctor not found"));

        Patients patient = new Patients();
        patient.setFirstName(appointmentDto.getPatientFirstName());
        patient.setLastName(appointmentDto.getPatientLastName());
        patient.setPhoneNumber(appointmentDto.getPatientPhoneNumber());

        Role patientRole = roleRepo.findByName("ROLE_PATIENT")
                .orElseThrow(() -> new RuntimeException("Role ROLE_PATIENT not found"));
        patient.setRole(patientRole);

        patientRepo.save(patient);

        Appointments appointment = new Appointments();
        appointment.setDoctor(doctor);
        appointment.setPatient(patient);

        appointmentRepo.save(appointment);

        return appointmentMapper.toDto(appointment);
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
