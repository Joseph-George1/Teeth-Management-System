package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.NotificationPreferenceDto;
import com.spring.boot.graduationproject1.model.NotificationPreference;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface NotificationPreferenceMapper {
    NotificationPreferenceDto toDto(NotificationPreference notificationPreference);
    NotificationPreference toEntity(NotificationPreferenceDto notificationPreferenceDto);
    List<NotificationPreferenceDto> toListDto(List<NotificationPreference> notificationPreferences);
    List<NotificationPreference> toListEntity(List<NotificationPreferenceDto> notificationPreferenceDtos);
}
