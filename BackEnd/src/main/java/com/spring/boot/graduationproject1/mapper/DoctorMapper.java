package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.DoctorDto;
import com.spring.boot.graduationproject1.dto.DoctorSummaryDto;
import com.spring.boot.graduationproject1.dto.SignUpRequest;
import com.spring.boot.graduationproject1.model.Doctor;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface DoctorMapper {
    DoctorDto toDto(Doctor doctor);
    Doctor toEntity(DoctorDto doctorDto);
    List<DoctorDto> toListDto(List<Doctor> doctors);
    List<Doctor> toListEntity(List<DoctorDto> doctorDtos);
    DoctorSummaryDto toSummaryDto(Doctor doctor);
    List<DoctorSummaryDto> toSummaryDtoList(List<Doctor> doctors);
    Doctor toEntity(SignUpRequest request);
}
