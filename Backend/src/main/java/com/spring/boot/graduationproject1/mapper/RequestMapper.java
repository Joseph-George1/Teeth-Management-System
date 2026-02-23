package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.RequestDto;
import com.spring.boot.graduationproject1.model.Requests;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface RequestMapper {
    RequestDto toDto(RequestDto requestDto);
    Requests toEntity(RequestDto requestDto);
    List<RequestDto>toListDto(List<Requests> requests);
    List<Requests>toListEntity(List<RequestDto> requestsDto);
}
