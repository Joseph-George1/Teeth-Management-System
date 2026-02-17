package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.UniversityDto;
import com.spring.boot.graduationproject1.model.University;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface UniversityMapper {
    UniversityDto toDto(University university);
    University toEntity(UniversityDto universityDto);
    List<UniversityDto> toListDto(List<University> universities);
    List<University> toListEntity(List<UniversityDto> universityDtos);
}
