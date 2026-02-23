package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.AppointmentDto;
import com.spring.boot.graduationproject1.model.Appointments;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface AppointmentMapper {
    AppointmentDto toDto(Appointments appointments);
    Appointments toEntity(AppointmentDto appointmentDto);
    List<AppointmentDto> toListDto(List<Appointments> appointments);
    List<Appointments> toListEntity(List<AppointmentDto> appointmentsDto);
}
