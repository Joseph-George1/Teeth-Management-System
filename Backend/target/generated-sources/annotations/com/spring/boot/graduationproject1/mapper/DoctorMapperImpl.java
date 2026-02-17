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
    date = "2026-02-18T10:17:15+0200",
    comments = "version: 1.5.2.Final, compiler: Eclipse JDT (IDE) 3.45.0.v20260128-0750, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class DoctorMapperImpl implements DoctorMapper {

    @Override
    public DoctorDto toDto(Doctor doctor) {
        if ( doctor == null ) {
            return null;
        }

        DoctorDto doctorDto = new DoctorDto();

        doctorDto.setCategoryName( doctor.getCategoryName() );
        doctorDto.setCityName( doctor.getCityName() );
        doctorDto.setEmail( doctor.getEmail() );
        doctorDto.setFirstName( doctor.getFirstName() );
        doctorDto.setId( doctor.getId() );
        doctorDto.setLastName( doctor.getLastName() );
        doctorDto.setPassword( doctor.getPassword() );
        doctorDto.setPhoneNumber( doctor.getPhoneNumber() );
        doctorDto.setRole( roleToRoleDto( doctor.getRole() ) );
        doctorDto.setStudyYear( doctor.getStudyYear() );
        doctorDto.setUniversityName( doctor.getUniversityName() );

        return doctorDto;
    }

    @Override
    public Doctor toEntity(DoctorDto doctorDto) {
        if ( doctorDto == null ) {
            return null;
        }

        Doctor doctor = new Doctor();

        doctor.setCategoryName( doctorDto.getCategoryName() );
        doctor.setCityName( doctorDto.getCityName() );
        doctor.setEmail( doctorDto.getEmail() );
        doctor.setFirstName( doctorDto.getFirstName() );
        doctor.setId( doctorDto.getId() );
        doctor.setLastName( doctorDto.getLastName() );
        doctor.setPassword( doctorDto.getPassword() );
        doctor.setPhoneNumber( doctorDto.getPhoneNumber() );
        doctor.setRole( roleDtoToRole( doctorDto.getRole() ) );
        doctor.setStudyYear( doctorDto.getStudyYear() );
        doctor.setUniversityName( doctorDto.getUniversityName() );

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

        doctorSummaryDto.setCategoryName( doctor.getCategoryName() );
        doctorSummaryDto.setCityName( doctor.getCityName() );
        doctorSummaryDto.setFirstName( doctor.getFirstName() );
        doctorSummaryDto.setLastName( doctor.getLastName() );
        doctorSummaryDto.setPhoneNumber( doctor.getPhoneNumber() );
        doctorSummaryDto.setStudyYear( doctor.getStudyYear() );
        doctorSummaryDto.setUniversityName( doctor.getUniversityName() );

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

        doctor.setCategoryName( request.getCategoryName() );
        doctor.setCityName( request.getCityName() );
        doctor.setEmail( request.getEmail() );
        doctor.setFirstName( request.getFirstName() );
        doctor.setLastName( request.getLastName() );
        doctor.setPassword( request.getPassword() );
        doctor.setPhoneNumber( request.getPhoneNumber() );
        doctor.setStudyYear( request.getStudyYear() );
        doctor.setUniversityName( request.getUniversityName() );

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
