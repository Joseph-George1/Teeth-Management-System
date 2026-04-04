package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class Patients extends User {
    @Column(name = "FIRST_NAME", nullable = false)
    private String firstName;
    @Column(name = "SUR_NAME", nullable = false)
    private String lastName;
    @Column(nullable = false)
    private String phoneNumber;
    @ManyToOne
    @JoinColumn(name = "role_id", nullable = false)
    private Role role;
    @OneToMany(mappedBy = "patient")
    private List<Appointments> appointments;
    
    @Override
    public String getUserType() {
        return "PATIENT";
    }
    
    @Override
    public String getIdentifier() {
        return this.phoneNumber;
    }
}