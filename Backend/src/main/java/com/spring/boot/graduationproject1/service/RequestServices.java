package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.RequestDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface RequestServices {

    List<RequestDto>getAllRequests();
    RequestDto getRequestById(Long id);
    RequestDto createRequest(Long doctorId, Long categoryId);
    void deleteRequest(Long id);
}
