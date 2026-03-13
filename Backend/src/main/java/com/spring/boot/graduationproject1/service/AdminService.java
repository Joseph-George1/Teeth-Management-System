package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.AdminDto;

public interface AdminService {
    AdminDto getAdminsByEmail(String email);
}
