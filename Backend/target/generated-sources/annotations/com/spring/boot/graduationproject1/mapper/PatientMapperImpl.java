package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.PatientDto;
import com.spring.boot.graduationproject1.model.Patients;
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
public class PatientMapperImpl implements PatientMapper {

    @Override
    public PatientDto toDto(Patients patient) {
        if ( patient == null ) {
            return null;
        }

        PatientDto patientDto = new PatientDto();

        patientDto.setCityName( patient.getCityName() );
        patientDto.setFirstName( patient.getFirstName() );
        patientDto.setId( patient.getId() );
        patientDto.setLastName( patient.getLastName() );
        patientDto.setPhoneNumber( patient.getPhoneNumber() );
        patientDto.setSurName( patient.getSurName() );

        return patientDto;
    }

    @Override
    public Patients toEntity(PatientDto patientDto) {
        if ( patientDto == null ) {
            return null;
        }

        Patients patients = new Patients();

        patients.setCityName( patientDto.getCityName() );
        patients.setFirstName( patientDto.getFirstName() );
        patients.setId( patientDto.getId() );
        patients.setLastName( patientDto.getLastName() );
        patients.setPhoneNumber( patientDto.getPhoneNumber() );
        patients.setSurName( patientDto.getSurName() );

        return patients;
    }

    @Override
    public List<PatientDto> toListDto(List<Patients> patients) {
        if ( patients == null ) {
            return null;
        }

        List<PatientDto> list = new ArrayList<PatientDto>( patients.size() );
        for ( Patients patients1 : patients ) {
            list.add( toDto( patients1 ) );
        }

        return list;
    }

    @Override
    public List<Patients> toListEntity(List<PatientDto> patientDtos) {
        if ( patientDtos == null ) {
            return null;
        }

        List<Patients> list = new ArrayList<Patients>( patientDtos.size() );
        for ( PatientDto patientDto : patientDtos ) {
            list.add( toEntity( patientDto ) );
        }

        return list;
    }
}
