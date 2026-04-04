package com.spring.boot.graduationproject1.repo;

import com.spring.boot.graduationproject1.model.NotificationPreference;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

/**
 * Repository for NotificationPreference entity
 * Handles database operations for user notification preferences
 */
public interface NotificationPreferenceRepo extends JpaRepository<NotificationPreference, Long> {
    
    /**
     * Find preferences by user ID
     */
    Optional<NotificationPreference> findByUserId(Long userId);
    
    /**
     * Check if user has preferences configured
     */
    Boolean existsByUserId(Long userId);
}
