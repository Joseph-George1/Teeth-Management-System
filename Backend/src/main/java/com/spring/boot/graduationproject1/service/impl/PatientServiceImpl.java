package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.dto.PatientDto;
import com.spring.boot.graduationproject1.mapper.DoctorMapper;
import com.spring.boot.graduationproject1.mapper.PatientMapper;
import com.spring.boot.graduationproject1.model.Doctor;
import com.spring.boot.graduationproject1.model.Patients;
import com.spring.boot.graduationproject1.repo.DoctorRepo;
import com.spring.boot.graduationproject1.repo.PatientRepo;
import com.spring.boot.graduationproject1.service.PatientService;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PatientServiceImpl implements PatientService {

    private final DoctorRepo doctorRepo;
    private final PatientRepo patientRepo;
    private final PatientMapper patientMapper;
    private final DoctorMapper doctorMapper;

    public PatientServiceImpl(DoctorRepo doctorRepo, PatientRepo patientRepo,PatientMapper patientMapper,DoctorMapper doctorMapper) {
        this.doctorRepo = doctorRepo;
        this.patientRepo = patientRepo;
        this.patientMapper = patientMapper;
        this.doctorMapper = doctorMapper;
    }




    @Override
    public List<PatientDto> getPatientByDoctorId() {
        Authentication authentication= SecurityContextHolder.getContext().getAuthentication();
        String email= authentication.getName();
        Doctor doctor= doctorRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));
        List<Patients> patients = patientRepo
                .findDistinctByAppointmentsDoctorId(doctor.getId());
        return patientMapper.toListDto(patients);
    }
}
