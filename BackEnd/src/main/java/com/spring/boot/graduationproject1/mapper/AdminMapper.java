package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.AdminDto;
import com.spring.boot.graduationproject1.model.Admin;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface AdminMapper {
    AdminDto toDto(Admin admin);
    Admin toEntity(AdminDto adminDto);
}
