package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.DoctorDto;
import com.spring.boot.graduationproject1.model.Doctor;
import javax.annotation.processing.Generated;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-10-28T21:56:26+0300",
    comments = "version: 1.5.2.Final, compiler: javac, environment: Java 17.0.12 (Oracle Corporation)"
)
@Component
public class DoctorMapperImpl implements DoctorMapper {

    @Autowired
    private RoleMapper roleMapper;

    @Override
    public DoctorDto toDto(Doctor doctor) {
        if ( doctor == null ) {
            return null;
        }

        DoctorDto doctorDto = new DoctorDto();

        doctorDto.setId( doctor.getId() );
        doctorDto.setName( doctor.getName() );
        doctorDto.setUniName( doctor.getUniName() );
        doctorDto.setCity( doctor.getCity() );
        doctorDto.setEmail( doctor.getEmail() );
        doctorDto.setPassword( doctor.getPassword() );
        doctorDto.setRole( roleMapper.toDto( doctor.getRole() ) );

        return doctorDto;
    }

    @Override
    public Doctor toEntity(DoctorDto doctorDto) {
        if ( doctorDto == null ) {
            return null;
        }

        Doctor doctor = new Doctor();

        doctor.setId( doctorDto.getId() );
        doctor.setName( doctorDto.getName() );
        doctor.setUniName( doctorDto.getUniName() );
        doctor.setCity( doctorDto.getCity() );
        doctor.setEmail( doctorDto.getEmail() );
        doctor.setPassword( doctorDto.getPassword() );
        doctor.setRole( roleMapper.toEntity( doctorDto.getRole() ) );

        return doctor;
    }
}
