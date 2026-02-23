package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.RoleDto;
import com.spring.boot.graduationproject1.model.Role;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-02-22T21:03:55+0200",
    comments = "version: 1.5.2.Final, compiler: javac, environment: Java 17.0.12 (Oracle Corporation)"
)
@Component
public class RoleMapperImpl implements RoleMapper {

    @Override
    public RoleDto toDto(Role role) {
        if ( role == null ) {
            return null;
        }

        RoleDto roleDto = new RoleDto();

        roleDto.setId( role.getId() );
        roleDto.setName( role.getName() );

        return roleDto;
    }

    @Override
    public Role toEntity(RoleMapper roleDto) {
        if ( roleDto == null ) {
            return null;
        }

        Role role = new Role();

        return role;
    }
}
