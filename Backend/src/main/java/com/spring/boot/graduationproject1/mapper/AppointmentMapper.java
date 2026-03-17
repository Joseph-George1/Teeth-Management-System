package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.AppointmentDto;
import com.spring.boot.graduationproject1.model.Appointments;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring")
public interface AppointmentMapper {
    @Mapping(source = "doctor.firstName", target = "doctorFirstName")
    @Mapping(source = "doctor.lastName", target = "doctorLastName")
    @Mapping(source = "doctor.phoneNumber", target = "doctorPhoneNumber")
    @Mapping(source = "doctor.cityName", target = "doctorCity")

    @Mapping(source = "patient.firstName", target = "patientFirstName")
    @Mapping(source = "patient.lastName", target = "patientLastName")
    @Mapping(source = "patient.phoneNumber", target = "patientPhoneNumber")

    @Mapping(source = "request.description", target = "requestDescription")
    @Mapping(source = "request.category.name", target = "categoryName")

    AppointmentDto toDto(Appointments appointments);
    Appointments toEntity(AppointmentDto appointmentDto);
    List<AppointmentDto> toListDto(List<Appointments> appointments);
    List<Appointments> toListEntity(List<AppointmentDto> appointmentsDto);
}
