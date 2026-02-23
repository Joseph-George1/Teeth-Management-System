package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.dto.RequestDto;
import com.spring.boot.graduationproject1.service.RequestServices;

import java.util.List;

public class RequestServiceImpl implements RequestServices {
    @Override
    public List<RequestDto> getAllRequests() {
        return List.of();
    }

    @Override
    public RequestDto getRequestById(Long id) {
        return null;
    }

    @Override
    public RequestDto createRequest(Long doctorId, Long categoryId) {
        return null;
    }

    @Override
    public void deleteRequest(Long id) {

    }
}
