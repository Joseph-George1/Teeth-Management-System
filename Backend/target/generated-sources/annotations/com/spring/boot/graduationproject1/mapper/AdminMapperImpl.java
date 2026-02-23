package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.AdminDto;
import com.spring.boot.graduationproject1.dto.RoleDto;
import com.spring.boot.graduationproject1.model.Admin;
import com.spring.boot.graduationproject1.model.Role;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-02-22T21:03:55+0200",
    comments = "version: 1.5.2.Final, compiler: javac, environment: Java 17.0.12 (Oracle Corporation)"
)
@Component
public class AdminMapperImpl implements AdminMapper {

    @Override
    public AdminDto toDto(Admin admin) {
        if ( admin == null ) {
            return null;
        }

        AdminDto adminDto = new AdminDto();

        adminDto.setId( admin.getId() );
        adminDto.setEmail( admin.getEmail() );
        adminDto.setPassword( admin.getPassword() );
        adminDto.setRole( roleToRoleDto( admin.getRole() ) );

        return adminDto;
    }

    @Override
    public Admin toEntity(AdminDto adminDto) {
        if ( adminDto == null ) {
            return null;
        }

        Admin admin = new Admin();

        admin.setId( adminDto.getId() );
        admin.setEmail( adminDto.getEmail() );
        admin.setPassword( adminDto.getPassword() );
        admin.setRole( roleDtoToRole( adminDto.getRole() ) );

        return admin;
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
