package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.CityDto;
import com.spring.boot.graduationproject1.model.City;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface CityMapper {
    CityDto toDto(City city);
    City toEntity(CityDto cityDto);
    List<CityDto> toDtoList(List<City> cityList);
    List<City> toEntityList(List<CityDto> cityDtoList);
}
