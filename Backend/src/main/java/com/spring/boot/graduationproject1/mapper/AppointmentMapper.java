package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.AppointmentDto;
import com.spring.boot.graduationproject1.model.Appointments;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

import java.util.List;

@Mapper(componentModel = "spring")
public interface AppointmentMapper {
    @Mapping(source = "doctor.firstName", target = "doctorFirstName")
    @Mapping(source = "doctor.lastName", target = "doctorLastName")
    @Mapping(source = "doctor.phoneNumber", target = "doctorPhoneNumber")
    @Mapping(source = "doctor.cityName", target = "doctorCity")

    @Mapping(source = "patientNameSnapshot", target = "patientFirstName", qualifiedByName = "getFirstName")
    @Mapping(source = "patientNameSnapshot", target = "patientLastName", qualifiedByName = "getLastName")
    @Mapping(source = "patientPhoneSnapshot", target = "patientPhoneNumber")

    @Mapping(source = "request.description", target = "requestDescription")
    @Mapping(source = "request.category.name", target = "categoryName")

    AppointmentDto toDto(Appointments appointments);
    Appointments toEntity(AppointmentDto appointmentDto);
    List<AppointmentDto> toListDto(List<Appointments> appointments);
    List<Appointments> toListEntity(List<AppointmentDto> appointmentsDto);


    @Named("getFirstName")
    default String getFirstName(String fullName) {
        if (fullName == null || fullName.isEmpty()) return "";
        return fullName.split(" ")[0];
    }

    @Named("getLastName")
    default String getLastName(String fullName) {
        if (fullName == null || fullName.isEmpty()) return "";
        String[] parts = fullName.split(" ");
        return parts.length > 1 ? parts[1] : "";
    }
}
