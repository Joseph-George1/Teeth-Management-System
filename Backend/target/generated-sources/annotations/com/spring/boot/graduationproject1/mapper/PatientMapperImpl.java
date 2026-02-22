package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.PatientDto;
import com.spring.boot.graduationproject1.model.Patients;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-02-22T21:03:55+0200",
    comments = "version: 1.5.2.Final, compiler: javac, environment: Java 17.0.12 (Oracle Corporation)"
)
@Component
public class PatientMapperImpl implements PatientMapper {

    @Override
    public PatientDto toDto(Patients patient) {
        if ( patient == null ) {
            return null;
        }

        PatientDto patientDto = new PatientDto();

        patientDto.setId( patient.getId() );
        patientDto.setFirstName( patient.getFirstName() );
        patientDto.setLastName( patient.getLastName() );
        patientDto.setSurName( patient.getSurName() );
        patientDto.setPhoneNumber( patient.getPhoneNumber() );
        patientDto.setCityName( patient.getCityName() );

        return patientDto;
    }

    @Override
    public Patients toEntity(PatientDto patientDto) {
        if ( patientDto == null ) {
            return null;
        }

        Patients patients = new Patients();

        patients.setId( patientDto.getId() );
        patients.setFirstName( patientDto.getFirstName() );
        patients.setLastName( patientDto.getLastName() );
        patients.setSurName( patientDto.getSurName() );
        patients.setPhoneNumber( patientDto.getPhoneNumber() );
        patients.setCityName( patientDto.getCityName() );

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
