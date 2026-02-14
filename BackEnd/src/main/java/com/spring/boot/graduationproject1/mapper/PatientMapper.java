package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.PatientDto;
import com.spring.boot.graduationproject1.model.Patients;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface PatientMapper {
    PatientDto toDto(Patients patient);
    Patients toEntity(PatientDto patientDto);
    List<PatientDto> toListDto(List<Patients> patients);
    List<Patients> toListEntity(List<PatientDto> patientDtos);
}
