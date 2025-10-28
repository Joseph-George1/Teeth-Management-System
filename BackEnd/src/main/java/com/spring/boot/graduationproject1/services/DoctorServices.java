package com.spring.boot.graduationproject1.services;

import com.spring.boot.graduationproject1.dto.DoctorDto;
import jakarta.transaction.SystemException;
import org.springframework.stereotype.Service;

@Service
public interface DoctorServices {
    DoctorDto signUp(DoctorDto doctorDto) throws SystemException;
    DoctorDto login(DoctorDto doctorDto);



}
