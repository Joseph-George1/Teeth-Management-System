package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.dto.CityDto;
import com.spring.boot.graduationproject1.mapper.CityMapper;
import com.spring.boot.graduationproject1.repo.CityRepo;
import com.spring.boot.graduationproject1.service.CityServices;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CityServiceImpl implements CityServices {


    private final CityRepo cityRepo;
    private final CityMapper cityMapper;

    public CityServiceImpl( CityRepo cityRepo, CityMapper cityMapper) {
        this.cityRepo = cityRepo;
        this.cityMapper = cityMapper;
    }

    @Override
    public List<CityDto> getCities() {
        return cityMapper.toDtoList(cityRepo.findAll());
    }

}
