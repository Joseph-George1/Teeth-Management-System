package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.PatientDto;
import com.spring.boot.graduationproject1.model.Patient;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring", uses = {RoleMapper.class})
public interface PatientMapper {
    PatientDto toDto(Patient patient);
    Patient toEntity(PatientDto patientDto);
}
