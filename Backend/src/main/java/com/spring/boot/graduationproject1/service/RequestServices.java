package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.RequestDto;

import java.util.List;

public interface RequestServices {

    List<RequestDto>getAllRequests();
    RequestDto getRequestById(Long id);
    RequestDto createRequest(RequestDto requestDto);
    RequestDto editRequest(Long requestId, RequestDto requestDto);
    void deleteRequest();
    List<RequestDto> getRequestByCategoryId(Long categoryId);
    List<RequestDto> getRequestByDoctorId();
}
