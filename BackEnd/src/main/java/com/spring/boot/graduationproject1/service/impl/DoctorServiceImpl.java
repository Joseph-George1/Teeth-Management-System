package com.spring.boot.graduationproject1.service.impl;


import com.spring.boot.graduationproject1.dto.DoctorDto;
import com.spring.boot.graduationproject1.dto.DoctorSummaryDto;
import com.spring.boot.graduationproject1.mapper.DoctorMapper;
import com.spring.boot.graduationproject1.model.Category;
import com.spring.boot.graduationproject1.model.City;
import com.spring.boot.graduationproject1.model.Doctor;
import com.spring.boot.graduationproject1.model.Role;
import com.spring.boot.graduationproject1.repo.CategoryRepo;
import com.spring.boot.graduationproject1.repo.CityRepo;
import com.spring.boot.graduationproject1.repo.DoctorRepo;
import com.spring.boot.graduationproject1.repo.RoleRepo;
import com.spring.boot.graduationproject1.service.DoctorService;
import jakarta.transaction.SystemException;
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

    public DoctorServiceImpl(DoctorRepo doctorRepo, CityRepo cityRepo, CategoryRepo categoryRepo, DoctorMapper doctorMapper, PasswordEncoder passwordEncoder,RoleRepo roleRepo) {
        this.doctorRepo = doctorRepo;
        this.cityRepo = cityRepo;
        this.categoryRepo = categoryRepo;
        this.doctorMapper = doctorMapper;
        this.passwordEncoder = passwordEncoder;
        this.roleRepo=roleRepo;
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

}
