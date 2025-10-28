package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.DoctorDto;
import com.spring.boot.graduationproject1.model.Doctor;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring", uses = {RoleMapper.class})
public interface DoctorMapper {

    DoctorDto toDto(Doctor doctor);

    Doctor toEntity(DoctorDto doctorDto);
}