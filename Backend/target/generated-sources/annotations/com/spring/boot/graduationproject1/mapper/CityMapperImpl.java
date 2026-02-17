package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.CityDto;
import com.spring.boot.graduationproject1.model.City;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-02-18T10:17:15+0200",
    comments = "version: 1.5.2.Final, compiler: Eclipse JDT (IDE) 3.45.0.v20260128-0750, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class CityMapperImpl implements CityMapper {

    @Override
    public CityDto toDto(City city) {
        if ( city == null ) {
            return null;
        }

        CityDto cityDto = new CityDto();

        cityDto.setId( city.getId() );
        cityDto.setName( city.getName() );

        return cityDto;
    }

    @Override
    public City toEntity(CityDto cityDto) {
        if ( cityDto == null ) {
            return null;
        }

        City city = new City();

        city.setId( cityDto.getId() );
        city.setName( cityDto.getName() );

        return city;
    }

    @Override
    public List<CityDto> toDtoList(List<City> cityList) {
        if ( cityList == null ) {
            return null;
        }

        List<CityDto> list = new ArrayList<CityDto>( cityList.size() );
        for ( City city : cityList ) {
            list.add( toDto( city ) );
        }

        return list;
    }

    @Override
    public List<City> toEntityList(List<CityDto> cityDtoList) {
        if ( cityDtoList == null ) {
            return null;
        }

        List<City> list = new ArrayList<City>( cityDtoList.size() );
        for ( CityDto cityDto : cityDtoList ) {
            list.add( toEntity( cityDto ) );
        }

        return list;
    }
}
