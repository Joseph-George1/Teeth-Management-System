package com.spring.boot.graduationproject1.service.impl;


import com.spring.boot.graduationproject1.config.jwt.TokenHandler;
import com.spring.boot.graduationproject1.controller.vm.AuthRequestVm;
import com.spring.boot.graduationproject1.controller.vm.AuthResponseVm;
import com.spring.boot.graduationproject1.dto.AdminDto;
import com.spring.boot.graduationproject1.dto.DoctorDto;
import com.spring.boot.graduationproject1.dto.SignUpRequest;
import com.spring.boot.graduationproject1.mapper.AdminMapper;
import com.spring.boot.graduationproject1.mapper.DoctorMapper;
import com.spring.boot.graduationproject1.model.*;
import com.spring.boot.graduationproject1.repo.*;
import com.spring.boot.graduationproject1.service.AdminService;
import com.spring.boot.graduationproject1.service.AuthService;
import com.spring.boot.graduationproject1.service.DoctorService;
import jakarta.transaction.SystemException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class AuthServiceImpl implements AuthService {

    private final AdminRepo adminRepo;
    private final AdminMapper adminMapper;
    private final DoctorService doctorService;
    private final PasswordEncoder passwordEncoder;
    private final TokenHandler tokenHandler;
    private final UniversityRepo universityRepo;
    private final CategoryRepo categoryRepo;
    private final RoleRepo roleRepo;
    private final DoctorMapper doctorMapper;
    private final CityRepo cityRepo;
    private final DoctorRepo doctorRepo;
    private final AdminService adminService;



    public AuthServiceImpl(DoctorService doctorService, PasswordEncoder passwordEncoder, TokenHandler tokenHandler,
                           UniversityRepo universityRepo, CategoryRepo categoryRepo, RoleRepo roleRepo, DoctorMapper doctorMapper
                            ,CityRepo cityRepo,DoctorRepo doctorRepo,AdminMapper adminMapper,AdminRepo adminRepo,AdminService adminService) {
        this.doctorService = doctorService;
        this.passwordEncoder = passwordEncoder;
        this.tokenHandler = tokenHandler;
        this.universityRepo = universityRepo;
        this.categoryRepo = categoryRepo;
        this.roleRepo = roleRepo;
        this.doctorMapper = doctorMapper;
        this.cityRepo = cityRepo;
        this.doctorRepo = doctorRepo;
        this.adminMapper = adminMapper;
        this.adminRepo = adminRepo;
        this.adminService = adminService;
    }


    @Override
    public AuthResponseVm loginDoctor(AuthRequestVm authRequestVm) throws SystemException {

        Doctor doctor = doctorRepo.findByEmail(authRequestVm.getEmail())
                .orElseThrow(() -> new SystemException("doctor.email.invalid"));

        if (!passwordEncoder.matches(authRequestVm.getPassword(), doctor.getPassword())) {
            throw new SystemException("doctor.email.invalid");
        }

        DoctorDto doctorDto = doctorMapper.toDto(doctor);

        Map<String, Object> claims = new HashMap<>();
        claims.put("firstName", doctorDto.getFirstName());
        claims.put("lastName", doctorDto.getLastName());

        String token = tokenHandler.createToken(
                doctorDto.getEmail(),
                "ROLE_DOCTOR",
                claims
        );

        return new AuthResponseVm(token);
    }

    @Override
    public AuthResponseVm loginAdmin(AuthRequestVm authRequestVm) throws SystemException {

        Admin admin = adminRepo.findByEmail(authRequestVm.getEmail())
                .orElseThrow(() -> new SystemException("doctor.email.invalid"));

        if (!passwordEncoder.matches(authRequestVm.getPassword(), admin.getPassword())) {
            throw new SystemException("doctor.email.invalid");
        }

        AdminDto adminDto = adminMapper.toDto(admin);

        String token = tokenHandler.createToken(
                adminDto.getEmail(),
                "ROLE_ADMIN",
                null
        );

        return new AuthResponseVm(token);
    }


    @Override
    public AuthResponseVm signup(SignUpRequest request) throws SystemException {

        // 1️⃣ check email
        if (doctorRepo.findByEmail(request.getEmail()).isPresent()) {
            throw new SystemException("Email already exists");
        }

        // 2️⃣ City
        City city = cityRepo.findByName(request.getCityName())
                .orElseGet(() -> {
                    City newCity = new City();
                    newCity.setName(request.getCityName());
                    return cityRepo.save(newCity);
                });

        // 3️⃣ Category
        Category category = categoryRepo.findByName(request.getCategoryName())
                .orElseGet(() -> {
                    Category newCategory = new Category();
                    newCategory.setName(request.getCategoryName());
                    return categoryRepo.save(newCategory);
                });

        // 4️⃣ University
        University university = universityRepo.findByName(request.getUniversityName())
                .orElseGet(() -> {
                    University newUniversity = new University();
                    newUniversity.setName(request.getUniversityName());
                    return universityRepo.save(newUniversity);
                });

        // 5️⃣ Role
        Role role = roleRepo.findByName("ROLE_DOCTOR")
                .orElseGet(() -> {
                    Role newRole = new Role();
                    newRole.setName("ROLE_DOCTOR");
                    return roleRepo.save(newRole);
                });

        // 6️⃣ Map request → entity
        Doctor doctor = doctorMapper.toEntity(request);

        doctor.setCity(city);
        doctor.setCategory(category);
        doctor.setUniversity(university);
        doctor.setRole(role);
        doctor.setPassword(passwordEncoder.encode(request.getPassword()));

        // 7️⃣ Save
        Doctor savedDoctor = doctorRepo.save(doctor);

        // 8️⃣ Entity → DTO
        DoctorDto doctorDto = doctorMapper.toDto(savedDoctor);

        // 9️⃣ JWT claims
        Map<String, Object> claims = new HashMap<>();
        claims.put("firstName", doctorDto.getFirstName());
        claims.put("lastName", doctorDto.getLastName());

        // 🔐 token
        String token = tokenHandler.createToken(
                doctorDto.getEmail(),
                "ROLE_DOCTOR",
                claims
        );

        // 🔁 response
        return new AuthResponseVm(token);
    }


}



