package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.CityDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface CityServices {
    List<CityDto> getCities();
}
