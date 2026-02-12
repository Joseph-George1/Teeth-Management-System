package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class City {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;
    @Column(nullable = false)
    private String name;

    @OneToMany(mappedBy = "city")
    private List<Doctor> doctor;
    @OneToMany(mappedBy = "city")
    private List<Patients> patients;
}
