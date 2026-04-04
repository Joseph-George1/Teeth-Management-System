package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Abstract base class for all user types (Doctor, Patient, Admin)
 * Provides common user interface for services
 */
@MappedSuperclass
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public abstract class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    protected Long id;
    
    /**
     * Get the user type (DOCTOR, PATIENT, ADMIN)
     * Implemented by subclasses
     */
    public abstract String getUserType();
    
    /**
     * Get user identifier for notifications
     */
    public abstract String getIdentifier();
}
