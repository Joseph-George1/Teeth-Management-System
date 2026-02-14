package com.spring.boot.graduationproject1.controller;

import com.spring.boot.graduationproject1.dto.CityDto;
import com.spring.boot.graduationproject1.service.CityServices;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/cities")
public class CityController {

    private final CityServices cityServices;

    public CityController(CityServices cityServices) {
        this.cityServices = cityServices;
    }

    @GetMapping("/getAllCities")
    public ResponseEntity<List<CityDto>> getCities() {
        return ResponseEntity.ok().body(cityServices.getCities());
    }


}
