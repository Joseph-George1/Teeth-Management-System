package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.UniversityDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface UniversityService {
    List<UniversityDto> getUniversities();
}
