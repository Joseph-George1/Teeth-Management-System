package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.UniversityDto;
import com.spring.boot.graduationproject1.model.University;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-02-22T21:03:55+0200",
    comments = "version: 1.5.2.Final, compiler: javac, environment: Java 17.0.12 (Oracle Corporation)"
)
@Component
public class UniversityMapperImpl implements UniversityMapper {

    @Override
    public UniversityDto toDto(University university) {
        if ( university == null ) {
            return null;
        }

        UniversityDto universityDto = new UniversityDto();

        universityDto.setId( university.getId() );
        universityDto.setName( university.getName() );
        universityDto.setCity( university.getCity() );
        universityDto.setLocation( university.getLocation() );
        universityDto.setLongitude( university.getLongitude() );
        universityDto.setLatitude( university.getLatitude() );

        return universityDto;
    }

    @Override
    public University toEntity(UniversityDto universityDto) {
        if ( universityDto == null ) {
            return null;
        }

        University university = new University();

        university.setId( universityDto.getId() );
        university.setName( universityDto.getName() );
        university.setCity( universityDto.getCity() );
        university.setLocation( universityDto.getLocation() );
        university.setLongitude( universityDto.getLongitude() );
        university.setLatitude( universityDto.getLatitude() );

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
