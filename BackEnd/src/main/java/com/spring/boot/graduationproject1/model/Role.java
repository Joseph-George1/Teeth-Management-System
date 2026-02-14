package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class Role {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;
    private String name; //Role_Doctor or Role_Patient

    @OneToMany(mappedBy = "role")
    private List<Doctor> doctors;

    @OneToMany(mappedBy = "role")
    private List<Patients> patients;

    @OneToMany(mappedBy = "role")
    private List<Admin> admins;
}
