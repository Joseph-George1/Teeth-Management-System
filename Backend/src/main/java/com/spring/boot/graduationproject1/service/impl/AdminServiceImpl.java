package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.dto.AdminDto;
import com.spring.boot.graduationproject1.dto.AppointmentDto;
import com.spring.boot.graduationproject1.dto.RequestDto;
import com.spring.boot.graduationproject1.mapper.AdminMapper;
import com.spring.boot.graduationproject1.mapper.AppointmentMapper;
import com.spring.boot.graduationproject1.mapper.RequestMapper;
import com.spring.boot.graduationproject1.model.Admin;
import com.spring.boot.graduationproject1.repo.AdminRepo;
import com.spring.boot.graduationproject1.repo.AppointmentRepo;
import com.spring.boot.graduationproject1.repo.RequestRepo;
import com.spring.boot.graduationproject1.service.AdminService;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.List;

@Service
public class AdminServiceImpl implements AdminService {
    private final AdminRepo adminRepo;
    private final AdminMapper adminMapper;
    private final AppointmentRepo appointmentRepo;
    private final AppointmentMapper appointmentMapper;
    private final RequestRepo requestRepo;
    private final RequestMapper requestMapper;

    public AdminServiceImpl(AdminRepo adminRepo, AdminMapper adminMapper, 
                          AppointmentRepo appointmentRepo, AppointmentMapper appointmentMapper,
                          RequestRepo requestRepo, RequestMapper requestMapper) {
        this.adminMapper = adminMapper;
        this.adminRepo = adminRepo;
        this.appointmentRepo = appointmentRepo;
        this.appointmentMapper = appointmentMapper;
        this.requestRepo = requestRepo;
        this.requestMapper = requestMapper;
    }

    @Override
    public AdminDto getAdminsByEmail(String email) {
        Optional<Admin> admin = adminRepo.findByEmail(email);
        if(admin.isEmpty()){
            throw new RuntimeException("No Such Admin");
        }
        return adminMapper.toDto(admin.get());
    }

    @Override
    public List<AppointmentDto> getAllAppointments() {
        return appointmentMapper.toListDto(appointmentRepo.findAll());
    }

    @Override
    public List<RequestDto> getAllRequests() {
        return requestMapper.toListDto(requestRepo.findAll());
    }

    @Override
    public List<AppointmentDto> getExpiredAppointments() {
        return appointmentMapper.toListDto(
            appointmentRepo.findByIsExpired(true)
        );
    }

    @Override
    public Long getTotalAppointments() {
        return appointmentRepo.count();
    }

    @Override
    public Long getTotalRequests() {
        return requestRepo.count();
    }
}
