package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class Admin extends User {
    @Column(nullable = false)
    public String email;
    @Column(nullable = false)
    public String password;

    @ManyToOne
    @JoinColumn(name = "role_id", nullable = false)
    private Role role;
    
    @Override
    public String getUserType() {
        return "ADMIN";
    }
    
    @Override
    public String getIdentifier() {
        return this.email;
    }
}
