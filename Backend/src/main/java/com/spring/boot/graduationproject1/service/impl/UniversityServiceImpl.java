package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.dto.UniversityDto;
import com.spring.boot.graduationproject1.mapper.UniversityMapper;
import com.spring.boot.graduationproject1.repo.UniversityRepo;
import com.spring.boot.graduationproject1.service.UniversityService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UniversityServiceImpl implements UniversityService {

    private final UniversityRepo universityRepo;
    private final UniversityMapper universityMapper;

    public UniversityServiceImpl(UniversityRepo universityRepo, UniversityMapper universityMapper) {
        this.universityRepo = universityRepo;
        this.universityMapper = universityMapper;
    }


    @Override
    public List<UniversityDto> getUniversities() {
        return universityMapper.toListDto(universityRepo.findAll());
    }
}
