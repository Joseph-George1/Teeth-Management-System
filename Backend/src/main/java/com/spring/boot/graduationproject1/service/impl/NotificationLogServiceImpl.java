package com.spring.boot.graduationproject1.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.spring.boot.graduationproject1.dto.NotificationLogDto;
import com.spring.boot.graduationproject1.mapper.NotificationLogMapper;
import com.spring.boot.graduationproject1.model.NotificationLog;
import com.spring.boot.graduationproject1.repo.NotificationLogRepo;
import com.spring.boot.graduationproject1.service.INotificationLogService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class NotificationLogServiceImpl implements INotificationLogService {
    
    private final NotificationLogRepo notificationLogRepo;
    private final NotificationLogMapper notificationLogMapper;
    
    public NotificationLogServiceImpl(NotificationLogRepo notificationLogRepo, 
                                     NotificationLogMapper notificationLogMapper) {
        this.notificationLogRepo = notificationLogRepo;
        this.notificationLogMapper = notificationLogMapper;
    }
    
    @Override
    public NotificationLogDto logNotification(
        Long recipientUserId,
        String recipientUserType,
        String title,
        String body,
        String notificationType,
        Long relatedEntityId,
        String relatedEntityType
    ) {
        NotificationLog log = new NotificationLog();
        log.setRecipientUserId(recipientUserId);
        log.setRecipientUserType(NotificationLog.DeliveryStatus.valueOf(recipientUserType.toUpperCase()));
        log.setTitle(title);
        log.setBody(body);
        log.setNotificationType(NotificationLog.NotificationType.valueOf(notificationType.toUpperCase()));
        log.setRelatedEntityId(relatedEntityId);
        log.setRelatedEntityType(relatedEntityType);
        log.setDeliveryStatus(NotificationLog.DeliveryStatus.PENDING);
        log.setIsRead(false);
        log.setSentAt(LocalDateTime.now());
        log.setCreatedAt(LocalDateTime.now());
        
        NotificationLog saved = notificationLogRepo.save(log);
        return notificationLogMapper.toDto(saved);
    }
    
    @Override
    public void updateFCMMessageId(Long notificationId, String fcmMessageId) {
        notificationLogRepo.findById(notificationId).ifPresent(log -> {
            log.setFcmMessageId(fcmMessageId);
            notificationLogRepo.save(log);
        });
    }
    
    @Override
    public void markAsDelivered(String fcmMessageId) {
        // This would need a custom query to find by FCM message ID
        // For now, implementing the interface method
    }
    
    @Override
    public void markAsRead(Long notificationId) {
        notificationLogRepo.findById(notificationId).ifPresent(log -> {
            log.setIsRead(true);
            log.setReadAt(LocalDateTime.now());
            notificationLogRepo.save(log);
        });
    }
    
    @Override
    public List<NotificationLogDto> getUserNotifications(Long userId, String userType) {
        return notificationLogRepo.findByRecipientUserIdAndRecipientUserTypeOrderByCreatedAtDesc(
            userId,
            NotificationLog.DeliveryStatus.valueOf(userType.toUpperCase())
        ).stream()
         .map(notificationLogMapper::toDto)
         .collect(Collectors.toList());
    }
    
    @Override
    public List<NotificationLogDto> getUnreadNotifications(Long userId, String userType) {
        return notificationLogRepo.findByRecipientUserIdAndRecipientUserTypeAndIsReadFalseOrderByCreatedAtDesc(
            userId,
            NotificationLog.DeliveryStatus.valueOf(userType.toUpperCase())
        ).stream()
         .map(notificationLogMapper::toDto)
         .collect(Collectors.toList());
    }
    
    @Override
    public Long countUnreadNotifications(Long userId, String userType) {
        return notificationLogRepo.countByRecipientUserIdAndRecipientUserTypeAndIsReadFalse(
            userId,
            NotificationLog.DeliveryStatus.valueOf(userType.toUpperCase())
        );
    }
    
    @Override
    public List<NotificationLogDto> getNotificationsByType(Long userId, String notificationType) {
        return notificationLogRepo.findByRecipientUserIdAndNotificationTypeOrderByCreatedAtDesc(
            userId,
            NotificationLog.NotificationType.valueOf(notificationType.toUpperCase())
        ).stream()
         .map(notificationLogMapper::toDto)
         .collect(Collectors.toList());
    }
    
    @Override
    public List<NotificationLogDto> getNotificationsByEntity(Long entityId, String entityType) {
        return notificationLogRepo.findByRelatedEntityIdAndRelatedEntityType(entityId, entityType)
            .stream()
            .map(notificationLogMapper::toDto)
            .collect(Collectors.toList());
    }
    
    @Override
    public List<NotificationLog> getFailedNotificationsForRetry() {
        LocalDateTime cutoffTime = LocalDateTime.now().minusHours(1);
        return notificationLogRepo.findByDeliveryStatusAndSentAtBefore(
            NotificationLog.DeliveryStatus.FAILED,
            cutoffTime
        );
    }
    
    @Override
    public void updateDeliveryStatus(Long notificationId, String status) {
        notificationLogRepo.findById(notificationId).ifPresent(log -> {
            log.setDeliveryStatus(NotificationLog.DeliveryStatus.valueOf(status.toUpperCase()));
            notificationLogRepo.save(log);
        });
    }
}
