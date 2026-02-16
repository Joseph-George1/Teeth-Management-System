package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import jakarta.persistence.Column;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "patient")
public class Patient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false)
    private String phoneNumber;
    @Column(nullable = false)
    private String name;
    @Column(nullable = false)
    private String city;

    @ManyToOne
    @JoinColumn(name = "role_id")
    private Role role;

}
