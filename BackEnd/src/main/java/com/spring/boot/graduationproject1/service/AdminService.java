package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.AdminDto;
import org.springframework.stereotype.Service;

@Service
public interface AdminService {
    AdminDto getAdminsByEmail(String email);
}
