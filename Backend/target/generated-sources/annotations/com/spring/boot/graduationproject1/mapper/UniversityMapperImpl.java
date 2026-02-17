package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.UniversityDto;
import com.spring.boot.graduationproject1.model.University;
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
public class UniversityMapperImpl implements UniversityMapper {

    @Override
    public UniversityDto toDto(University university) {
        if ( university == null ) {
            return null;
        }

        UniversityDto universityDto = new UniversityDto();

        universityDto.setCity( university.getCity() );
        universityDto.setId( university.getId() );
        universityDto.setLatitude( university.getLatitude() );
        universityDto.setLocation( university.getLocation() );
        universityDto.setLongitude( university.getLongitude() );
        universityDto.setName( university.getName() );

        return universityDto;
    }

    @Override
    public University toEntity(UniversityDto universityDto) {
        if ( universityDto == null ) {
            return null;
        }

        University university = new University();

        university.setCity( universityDto.getCity() );
        university.setId( universityDto.getId() );
        university.setLatitude( universityDto.getLatitude() );
        university.setLocation( universityDto.getLocation() );
        university.setLongitude( universityDto.getLongitude() );
        university.setName( universityDto.getName() );

        return university;
    }

    @Override
    public List<UniversityDto> toListDto(List<University> universities) {
        if ( universities == null ) {
            return null;
        }

        List<UniversityDto> list = new ArrayList<UniversityDto>( universities.size() );
        for ( University university : universities ) {
            list.add( toDto( university ) );
        }

        return list;
    }

    @Override
    public List<University> toListEntity(List<UniversityDto> universityDtos) {
        if ( universityDtos == null ) {
            return null;
        }

        List<University> list = new ArrayList<University>( universityDtos.size() );
        for ( UniversityDto universityDto : universityDtos ) {
            list.add( toEntity( universityDto ) );
        }

        return list;
    }
}
