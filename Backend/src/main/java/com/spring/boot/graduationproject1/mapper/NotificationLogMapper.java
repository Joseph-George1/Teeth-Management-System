package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.NotificationLogDto;
import com.spring.boot.graduationproject1.model.NotificationLog;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface NotificationLogMapper {
    NotificationLogDto toDto(NotificationLog notificationLog);
    NotificationLog toEntity(NotificationLogDto notificationLogDto);
    List<NotificationLogDto> toListDto(List<NotificationLog> notificationLogs);
    List<NotificationLog> toListEntity(List<NotificationLogDto> notificationLogDtos);
}
