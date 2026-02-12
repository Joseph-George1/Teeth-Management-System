package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.dto.AdminDto;
import com.spring.boot.graduationproject1.mapper.AdminMapper;
import com.spring.boot.graduationproject1.model.Admin;
import com.spring.boot.graduationproject1.repo.AdminRepo;
import com.spring.boot.graduationproject1.service.AdminService;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class AdminServiceImpl implements AdminService {
    private final AdminRepo adminRepo;
    private final AdminMapper adminMapper;

    public AdminServiceImpl(AdminRepo adminRepo, AdminMapper adminMapper) {
        this.adminMapper=adminMapper;
        this.adminRepo=adminRepo;

    }

    @Override
    public AdminDto getAdminsByEmail(String email) {
        Optional<Admin> admin=adminRepo.findByEmail(email);
        if(admin.isEmpty()){
            throw new RuntimeException("No Such Doctor");
        }
        return adminMapper.toDto(admin.get());
    }
}
