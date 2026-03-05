package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.dto.RequestDto;
import com.spring.boot.graduationproject1.mapper.RequestMapper;
import com.spring.boot.graduationproject1.model.Category;
import com.spring.boot.graduationproject1.model.Doctor;
import com.spring.boot.graduationproject1.model.Requests;
import com.spring.boot.graduationproject1.repo.CategoryRepo;
import com.spring.boot.graduationproject1.repo.DoctorRepo;
import com.spring.boot.graduationproject1.repo.RequestRepo;
import com.spring.boot.graduationproject1.service.RequestServices;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class RequestServiceImpl implements RequestServices {

    private final RequestRepo requestRepo;
    private final RequestMapper requestMapper;
    private final DoctorRepo doctorRepo;
    private final CategoryRepo categoryRepo;

    public RequestServiceImpl(RequestRepo requestRepo, RequestMapper requestMapper,
                              DoctorRepo doctorRepo, CategoryRepo categoryRepo) {
        this.requestRepo = requestRepo;
        this.requestMapper = requestMapper;
        this.doctorRepo = doctorRepo;
        this.categoryRepo = categoryRepo;
    }

    @Override
    public List<RequestDto> getAllRequests() {
        return requestMapper.toListDto(requestRepo.findAll());
    }

    @Override
    public RequestDto getRequestById(Long id) {
        Optional<Requests> request = requestRepo.findById(id);
        if (request.isEmpty()) {
            throw new RuntimeException("No such request");
        }
        return requestMapper.toDto(request.get());
    }

    @Override
    public RequestDto createRequest(RequestDto requestDto) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        Doctor doctor = doctorRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));

        Category category = doctor.getCategory();

        Requests request = new Requests();
        request.setDoctor(doctor);
        request.setCategory(category);
        request.setStatus("PENDING");

        request.setDescription(requestDto.getDescription());
        request.setDateTime(requestDto.getDateTime());

        requestRepo.save(request);

        return requestMapper.toDto(request);
    }

    @Override
    public void deleteRequest() {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        Doctor doctor = doctorRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));

        Requests request = requestRepo.findByDoctor(doctor)
                .orElseThrow(() -> new RuntimeException("Request not found"));

        requestRepo.delete(request);
    }
}
