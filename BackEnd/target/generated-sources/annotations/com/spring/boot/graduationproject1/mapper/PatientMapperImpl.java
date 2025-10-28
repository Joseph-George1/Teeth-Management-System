package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.PatientDto;
import com.spring.boot.graduationproject1.model.Patient;
import javax.annotation.processing.Generated;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-10-28T21:56:26+0300",
    comments = "version: 1.5.2.Final, compiler: javac, environment: Java 17.0.12 (Oracle Corporation)"
)
@Component
public class PatientMapperImpl implements PatientMapper {

    @Autowired
    private RoleMapper roleMapper;

    @Override
    public PatientDto toDto(Patient patient) {
        if ( patient == null ) {
            return null;
        }

        PatientDto patientDto = new PatientDto();

        patientDto.setId( patient.getId() );
        patientDto.setName( patient.getName() );
        patientDto.setCity( patient.getCity() );
        patientDto.setPhoneNumber( patient.getPhoneNumber() );
        patientDto.setRole( roleMapper.toDto( patient.getRole() ) );

        return patientDto;
    }

    @Override
    public Patient toEntity(PatientDto patientDto) {
        if ( patientDto == null ) {
            return null;
        }

        Patient patient = new Patient();

        patient.setId( patientDto.getId() );
        patient.setPhoneNumber( patientDto.getPhoneNumber() );
        patient.setName( patientDto.getName() );
        patient.setCity( patientDto.getCity() );
        patient.setRole( roleMapper.toEntity( patientDto.getRole() ) );

        return patient;
    }
}
