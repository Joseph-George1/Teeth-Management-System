package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.DoctorDto;
import com.spring.boot.graduationproject1.dto.DoctorSummaryDto;
import com.spring.boot.graduationproject1.dto.RoleDto;
import com.spring.boot.graduationproject1.dto.SignUpRequest;
import com.spring.boot.graduationproject1.model.Doctor;
import com.spring.boot.graduationproject1.model.Role;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-02-06T20:36:33+0200",
    comments = "version: 1.5.2.Final, compiler: javac, environment: Java 17.0.12 (Oracle Corporation)"
)
@Component
public class DoctorMapperImpl implements DoctorMapper {

    @Override
    public DoctorDto toDto(Doctor doctor) {
        if ( doctor == null ) {
            return null;
        }

        DoctorDto doctorDto = new DoctorDto();

        doctorDto.setId( doctor.getId() );
        doctorDto.setCategoryName( doctor.getCategoryName() );
        doctorDto.setUniversityName( doctor.getUniversityName() );
        doctorDto.setFirstName( doctor.getFirstName() );
        doctorDto.setLastName( doctor.getLastName() );
        doctorDto.setEmail( doctor.getEmail() );
        doctorDto.setStudyYear( doctor.getStudyYear() );
        doctorDto.setPassword( doctor.getPassword() );
        doctorDto.setPhoneNumber( doctor.getPhoneNumber() );
        doctorDto.setCityName( doctor.getCityName() );
        doctorDto.setRole( roleToRoleDto( doctor.getRole() ) );

        return doctorDto;
    }

    @Override
    public Doctor toEntity(DoctorDto doctorDto) {
        if ( doctorDto == null ) {
            return null;
        }

        Doctor doctor = new Doctor();

        doctor.setId( doctorDto.getId() );
        doctor.setFirstName( doctorDto.getFirstName() );
        doctor.setLastName( doctorDto.getLastName() );
        doctor.setEmail( doctorDto.getEmail() );
        doctor.setPassword( doctorDto.getPassword() );
        doctor.setStudyYear( doctorDto.getStudyYear() );
        doctor.setPhoneNumber( doctorDto.getPhoneNumber() );
        doctor.setCityName( doctorDto.getCityName() );
        doctor.setUniversityName( doctorDto.getUniversityName() );
        doctor.setCategoryName( doctorDto.getCategoryName() );
        doctor.setRole( roleDtoToRole( doctorDto.getRole() ) );

        return doctor;
    }

    @Override
    public List<DoctorDto> toListDto(List<Doctor> doctors) {
        if ( doctors == null ) {
            return null;
        }

        List<DoctorDto> list = new ArrayList<DoctorDto>( doctors.size() );
        for ( Doctor doctor : doctors ) {
            list.add( toDto( doctor ) );
        }

        return list;
    }

    @Override
    public List<Doctor> toListEntity(List<DoctorDto> doctorDtos) {
        if ( doctorDtos == null ) {
            return null;
        }

        List<Doctor> list = new ArrayList<Doctor>( doctorDtos.size() );
        for ( DoctorDto doctorDto : doctorDtos ) {
            list.add( toEntity( doctorDto ) );
        }

        return list;
    }

    @Override
    public DoctorSummaryDto toSummaryDto(Doctor doctor) {
        if ( doctor == null ) {
            return null;
        }

        DoctorSummaryDto doctorSummaryDto = new DoctorSummaryDto();

        doctorSummaryDto.setFirstName( doctor.getFirstName() );
        doctorSummaryDto.setLastName( doctor.getLastName() );
        doctorSummaryDto.setStudyYear( doctor.getStudyYear() );
        doctorSummaryDto.setPhoneNumber( doctor.getPhoneNumber() );
        doctorSummaryDto.setUniversityName( doctor.getUniversityName() );
        doctorSummaryDto.setCityName( doctor.getCityName() );
        doctorSummaryDto.setCategoryName( doctor.getCategoryName() );

        return doctorSummaryDto;
    }

    @Override
    public List<DoctorSummaryDto> toSummaryDtoList(List<Doctor> doctors) {
        if ( doctors == null ) {
            return null;
        }

        List<DoctorSummaryDto> list = new ArrayList<DoctorSummaryDto>( doctors.size() );
        for ( Doctor doctor : doctors ) {
            list.add( toSummaryDto( doctor ) );
        }

        return list;
    }

    @Override
    public Doctor toEntity(SignUpRequest request) {
        if ( request == null ) {
            return null;
        }

        Doctor doctor = new Doctor();

        doctor.setFirstName( request.getFirstName() );
        doctor.setLastName( request.getLastName() );
        doctor.setEmail( request.getEmail() );
        doctor.setPassword( request.getPassword() );
        doctor.setStudyYear( request.getStudyYear() );
        doctor.setPhoneNumber( request.getPhoneNumber() );
        doctor.setCityName( request.getCityName() );
        doctor.setUniversityName( request.getUniversityName() );
        doctor.setCategoryName( request.getCategoryName() );

        return doctor;
    }

    protected RoleDto roleToRoleDto(Role role) {
        if ( role == null ) {
            return null;
        }

        RoleDto roleDto = new RoleDto();

        roleDto.setId( role.getId() );
        roleDto.setName( role.getName() );

        return roleDto;
    }

    protected Role roleDtoToRole(RoleDto roleDto) {
        if ( roleDto == null ) {
            return null;
        }

        Role role = new Role();

        role.setId( roleDto.getId() );
        role.setName( roleDto.getName() );

        return role;
    }
}
