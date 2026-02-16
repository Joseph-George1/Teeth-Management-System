package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.RoleDto;
import com.spring.boot.graduationproject1.model.Role;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface RoleMapper {
    RoleDto toDto(Role role);
    Role toEntity(RoleDto roleDto);
}
