package com.spring.boot.graduationproject1.service.impl;


import com.spring.boot.graduationproject1.dto.DoctorDto;
import com.spring.boot.graduationproject1.dto.DoctorRepresentDto;
import com.spring.boot.graduationproject1.dto.DoctorSummaryDto;
import com.spring.boot.graduationproject1.mapper.DoctorMapper;
import com.spring.boot.graduationproject1.model.*;
import com.spring.boot.graduationproject1.repo.*;
import com.spring.boot.graduationproject1.service.DoctorService;
import com.spring.boot.graduationproject1.service.UniversityService;
import jakarta.transaction.SystemException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Objects;
import java.util.Optional;


@Service
public class DoctorServiceImpl implements DoctorService {

    private final DoctorRepo doctorRepo;
    private final CityRepo cityRepo;
    private final CategoryRepo categoryRepo;
    private final DoctorMapper doctorMapper;
    private final PasswordEncoder passwordEncoder;
    private final RoleRepo roleRepo;
    private final UniversityRepo universityRepo;
    private final AppointmentRepo appointmentRepo;
    private final RequestRepo requestRepo;


    public DoctorServiceImpl(DoctorRepo doctorRepo, CityRepo cityRepo, CategoryRepo categoryRepo,
                             DoctorMapper doctorMapper, PasswordEncoder passwordEncoder,RoleRepo roleRepo,
                             UniversityRepo universityRepo, AppointmentRepo appointmentRepo, RequestRepo requestRepo) {
        this.doctorRepo = doctorRepo;
        this.cityRepo = cityRepo;
        this.categoryRepo = categoryRepo;
        this.doctorMapper = doctorMapper;
        this.passwordEncoder = passwordEncoder;
        this.roleRepo=roleRepo;
        this.universityRepo=universityRepo;
        this.appointmentRepo = appointmentRepo;
        this.requestRepo = requestRepo;
    }

    @Override
    public List<DoctorSummaryDto> getDoctors() {
        return doctorMapper.toSummaryDtoList(doctorRepo.findAll());
    }

    @Override
    public List<DoctorSummaryDto> getDoctorsByCityId(Long cityId) throws SystemException {
        City city = cityRepo.findById(cityId)
                .orElseThrow(() -> new SystemException("No Such City"));

        return doctorMapper.toSummaryDtoList(doctorRepo.findByCity(city));
    }

    @Override
    public List<DoctorSummaryDto> getDoctorByCategoryId(Long categoryId) throws SystemException {
        Category category = categoryRepo.findById(categoryId)
                .orElseThrow(() -> new SystemException("No Such Category"));

        return doctorMapper.toSummaryDtoList(doctorRepo.findByCategory(category));
    }

    @Override
    public DoctorDto getDoctorByEmail(String email)  {
        Optional<Doctor>doctor=doctorRepo.findByEmail(email);
        if(doctor.isEmpty()){
            throw new RuntimeException("No Such Doctor");
        }
        return doctorMapper.toDto(doctor.get());
    }

    @Override
    public Doctor saveDoctor(Doctor doctor) throws SystemException {

        if (doctor.getId() != null) {
            throw new SystemException("Id Not Required");
        }

        if (doctorRepo.findByEmail(doctor.getEmail()).isPresent()) {
            throw new SystemException("Email Already Exists");
        }
        return doctorRepo.save(doctor);
    }

    @Override
    public DoctorDto updateDoctor(DoctorDto doctorDto) throws SystemException {

        String email = SecurityContextHolder
                .getContext()
                .getAuthentication()
                .getName();

        Doctor doctor = doctorRepo.findByEmail(email)
                .orElseThrow(() -> new SystemException("Doctor Not Found"));

        if (doctorDto.getFirstName() != null) {
            doctor.setFirstName(doctorDto.getFirstName());
        }

        if (doctorDto.getLastName() != null) {
            doctor.setLastName(doctorDto.getLastName());
        }

        if (doctorDto.getPhoneNumber() != null) {
            doctor.setPhoneNumber(doctorDto.getPhoneNumber());
        }

        if (doctorDto.getPassword() != null) {
            doctor.setPassword(passwordEncoder.encode(doctorDto.getPassword()));
        }

        if (doctorDto.getStudyYear() != null) {
            doctor.setStudyYear(doctorDto.getStudyYear());
        }

        if (doctorDto.getCityName() != null) {
            City city = cityRepo
                    .findByName(doctorDto.getCityName())
                    .orElseThrow(() -> new SystemException("No Such City"));

            doctor.setCity(city);
            doctor.setCityName(city.getName());
        }

        if (doctorDto.getCategoryName() != null) {
            Category category = categoryRepo
                    .findByName(doctorDto.getCategoryName())
                    .orElseThrow(() -> new SystemException("No Such Category"));

            doctor.setCategory(category);
            doctor.setCategoryName(category.getName());
        }

        if (doctorDto.getUniversityName() != null) {
            University university = universityRepo
                    .findByName(doctorDto.getUniversityName())
                    .orElseThrow(() -> new SystemException("No Such University"));

            doctor.setUniversity(university);
            doctor.setUniversityName(university.getName());
        }

        doctorRepo.save(doctor);

        return doctorMapper.toDto(doctor);
    }



    @Override
    public DoctorRepresentDto getDoctorById() throws SystemException{
        Authentication authentication=SecurityContextHolder.getContext().getAuthentication();
        String email=authentication.getName();
        Doctor doctor = doctorRepo.findByEmail(email)
                .orElseThrow(() -> new SystemException("Doctor not found"));

        return doctorMapper.toRepresentDto(doctor);
    }

    @Override
    public void deleteDoctorByAdmin(long doctorId) {
        Doctor doctor = doctorRepo.findById(doctorId)
                .orElseThrow(() -> new RuntimeException("No Such Doctor"));

        // Delete related appointments first to avoid foreign key violations
        List<Appointments> appointments = appointmentRepo.findByDoctorId(doctorId);
        if (!appointments.isEmpty()) {
            appointmentRepo.deleteAll(appointments);
        }

        // Delete related requests
        List<Requests> requests = requestRepo.findByDoctor(doctor);
        if (!requests.isEmpty()) {
            requestRepo.deleteAll(requests);
        }

        doctorRepo.delete(doctor);
    }

    @Override
    public void deleteDoctor() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        Doctor doctor = doctorRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));

        // Delete related appointments first
        List<Appointments> appointments = appointmentRepo.findByDoctorId(doctor.getId());
        if (!appointments.isEmpty()) {
            appointmentRepo.deleteAll(appointments);
        }

        // Delete related requests
        List<Requests> requests = requestRepo.findByDoctor(doctor);
        if (!requests.isEmpty()) {
            requestRepo.deleteAll(requests);
        }

        doctorRepo.delete(doctor);
    }

}
