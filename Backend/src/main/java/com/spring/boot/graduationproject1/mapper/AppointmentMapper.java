package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.AppointmentDto;
import com.spring.boot.graduationproject1.model.Appointments;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring")
public interface AppointmentMapper {
    @Mapping(source = "doctor.id", target = "doctorId")
    @Mapping(source = "doctor.firstName", target = "doctorFirstName")
    @Mapping(source = "doctor.lastName", target = "doctorLastName")

    @Mapping(source = "patient.id", target = "patientId")
    @Mapping(source = "patient.firstName", target = "patientFirstName")
    @Mapping(source = "patient.lastName", target = "patientLastName")
    AppointmentDto toDto(Appointments appointments);
    Appointments toEntity(AppointmentDto appointmentDto);
    List<AppointmentDto> toListDto(List<Appointments> appointments);
    List<Appointments> toListEntity(List<AppointmentDto> appointmentsDto);
}
