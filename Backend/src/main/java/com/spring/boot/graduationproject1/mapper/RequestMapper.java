package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.RequestDto;
import com.spring.boot.graduationproject1.model.Requests;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring")
public interface RequestMapper {

    @Mapping(source = "Id", target = "id")
    @Mapping(source = "doctor.firstName", target = "doctorFirstName")
    @Mapping(source = "doctor.lastName", target = "doctorLastName")
    @Mapping(source = "doctor.phoneNumber", target = "doctorPhoneNumber")
    @Mapping(source = "doctor.cityName", target = "doctorCityName")
    @Mapping(source = "doctor.universityName", target = "doctorUniversityName")
    @Mapping(source = "category.name", target = "categoryName")
    RequestDto toDto(Requests request);
    Requests toEntity(RequestDto requestDto);
    List<RequestDto>toListDto(List<Requests> requests);
    List<Requests>toListEntity(List<RequestDto> requestsDto);
}
