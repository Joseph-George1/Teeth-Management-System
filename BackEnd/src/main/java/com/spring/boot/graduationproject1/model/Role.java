package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "role")
@Getter
@Setter
public class Role {
    @Id
    private Long id;

    private String name; //Role_Doctor or Role_Patient

    @OneToMany(mappedBy = "role")
    private List<Doctor> doctors;

    @OneToMany(mappedBy = "role")
    private List<Patient> patients;

}
