package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.DoctorDto;
import com.spring.boot.graduationproject1.model.Doctor;
import javax.annotation.processing.Generated;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-19T14:05:34+0200",
    comments = "version: 1.5.2.Final, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
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

        doctorDto.setCity( doctor.getCity() );
        doctorDto.setEmail( doctor.getEmail() );
        doctorDto.setId( doctor.getId() );
        doctorDto.setName( doctor.getName() );
        doctorDto.setPassword( doctor.getPassword() );
        doctorDto.setRole( roleMapper.toDto( doctor.getRole() ) );
        doctorDto.setStudyYear( doctor.getStudyYear() );
        doctorDto.setUniName( doctor.getUniName() );

        return doctorDto;
    }

    @Override
    public Doctor toEntity(DoctorDto doctorDto) {
        if ( doctorDto == null ) {
            return null;
        }

        Doctor doctor = new Doctor();

        doctor.setCity( doctorDto.getCity() );
        doctor.setEmail( doctorDto.getEmail() );
        doctor.setId( doctorDto.getId() );
        doctor.setName( doctorDto.getName() );
        doctor.setPassword( doctorDto.getPassword() );
        doctor.setRole( roleMapper.toEntity( doctorDto.getRole() ) );
        doctor.setStudyYear( doctorDto.getStudyYear() );
        doctor.setUniName( doctorDto.getUniName() );

        return doctor;
    }
}
