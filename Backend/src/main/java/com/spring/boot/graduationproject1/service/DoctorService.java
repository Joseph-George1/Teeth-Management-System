package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.DoctorDto;
import com.spring.boot.graduationproject1.dto.DoctorSummaryDto;
import com.spring.boot.graduationproject1.model.Doctor;
import jakarta.transaction.SystemException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface DoctorService {
List<DoctorSummaryDto> getDoctors();
List<DoctorSummaryDto> getDoctorsByCityId(Long cityId) throws SystemException;
List<DoctorSummaryDto> getDoctorByCategoryId(Long categoryId) throws SystemException;
DoctorDto getDoctorByEmail(String email);
Doctor saveDoctor(Doctor doctor) throws SystemException;
DoctorDto updateDoctor(DoctorDto doctorDto) throws SystemException;
DoctorDto getDoctorById(Long doctorId) throws SystemException;
}
