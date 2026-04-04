package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.DeviceTokenDto;
import com.spring.boot.graduationproject1.model.DeviceToken;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface DeviceTokenMapper {
    DeviceTokenDto toDto(DeviceToken deviceToken);
    DeviceToken toEntity(DeviceTokenDto deviceTokenDto);
    List<DeviceTokenDto> toListDto(List<DeviceToken> deviceTokens);
    List<DeviceToken> toListEntity(List<DeviceTokenDto> deviceTokenDtos);
}
