package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.dto.RequestDto;
import com.spring.boot.graduationproject1.mapper.RequestMapper;
import com.spring.boot.graduationproject1.model.Appointments;
import com.spring.boot.graduationproject1.model.Category;
import com.spring.boot.graduationproject1.model.Doctor;
import com.spring.boot.graduationproject1.model.Requests;
import com.spring.boot.graduationproject1.repo.*;
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
    private final AppointmentRepo appointmentRepo;

    public RequestServiceImpl(RequestRepo requestRepo, RequestMapper requestMapper,
                              DoctorRepo doctorRepo, CategoryRepo categoryRepo,AppointmentRepo appointmentRepo) {
        this.requestRepo = requestRepo;
        this.requestMapper = requestMapper;
        this.doctorRepo = doctorRepo;
        this.categoryRepo = categoryRepo;
        this.appointmentRepo = appointmentRepo;
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
    public RequestDto editRequest(Long requestId, RequestDto requestDto) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        Doctor doctor = doctorRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));

        Requests request = requestRepo.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found"));

        // Verify doctor owns this request
        if (!request.getDoctor().getId().equals(doctor.getId())) {
            throw new RuntimeException("You can only edit your own requests");
        }

        // Only allow editing if status is PENDING (before patients book)
        if (!request.getStatus().equals("PENDING")) {
            throw new RuntimeException("Can only edit PENDING requests");
        }

        // === Doctor can edit description and dateTime ===
        if (requestDto.getDescription() != null) {
            request.setDescription(requestDto.getDescription());
        }
        if (requestDto.getDateTime() != null) {
            request.setDateTime(requestDto.getDateTime());
        }

        requestRepo.save(request);
        return requestMapper.toDto(request);
    }

    @Override
    public void deleteRequest(Long requestId) {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();


        Doctor doctor = doctorRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));


        Requests request = requestRepo.findByIdAndDoctor(requestId, doctor)
                .orElseThrow(() -> new RuntimeException("Request not found"));


        List<Appointments> apps = appointmentRepo.findByRequestId(requestId);

        for (Appointments app : apps) {
            app.setRequest(null);
        }

        appointmentRepo.saveAll(apps);
        requestRepo.deleteById(requestId);
    }

    @Override
    public List<RequestDto> getRequestByCategoryId(Long categoryId) {
        if (!categoryRepo.existsById(categoryId)) {
            throw new RuntimeException("Category not found");
        }


        List<Requests> requests = requestRepo.findByCategoryId(categoryId);


        return requestMapper.toListDto(requests);
    }

    @Override
    public List<RequestDto> getRequestByDoctorId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        Doctor doctor = doctorRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));


        List<Requests> requests = requestRepo.findByDoctor(doctor);

        return requestMapper.toListDto(requests);
    }

    @Override
    public void updateRequestStatus(Long requestId, String status) {
        Requests request = requestRepo.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found"));
        request.setStatus(status);
        requestRepo.save(request);
    }
}
