package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.controller.vm.AuthRequestVm;
import com.spring.boot.graduationproject1.controller.vm.AuthResponseVm;
import com.spring.boot.graduationproject1.dto.DoctorDto;
import com.spring.boot.graduationproject1.dto.SignUpRequest;
import jakarta.transaction.SystemException;
import org.springframework.stereotype.Service;

@Service
public interface AuthService {
AuthResponseVm loginDoctor(AuthRequestVm authRequestVm)throws SystemException;
AuthResponseVm loginAdmin(AuthRequestVm authRequestVm)throws SystemException;
AuthResponseVm signup(SignUpRequest request)throws SystemException;
}
