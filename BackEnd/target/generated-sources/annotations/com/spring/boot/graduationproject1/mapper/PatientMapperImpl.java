package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.PatientDto;
import com.spring.boot.graduationproject1.model.Patient;
import javax.annotation.processing.Generated;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-01-15T10:26:53+0200",
    comments = "version: 1.5.2.Final, compiler: Eclipse JDT (IDE) 3.45.0.v20260101-2150, environment: Java 21.0.9 (Eclipse Adoptium)"
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

        patientDto.setCity( patient.getCity() );
        patientDto.setId( patient.getId() );
        patientDto.setName( patient.getName() );
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

        patient.setCity( patientDto.getCity() );
        patient.setId( patientDto.getId() );
        patient.setName( patientDto.getName() );
        patient.setPhoneNumber( patientDto.getPhoneNumber() );
        patient.setRole( roleMapper.toEntity( patientDto.getRole() ) );

        return patient;
    }
}
