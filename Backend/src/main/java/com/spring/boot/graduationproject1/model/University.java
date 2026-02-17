package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class University {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;
    @Column(nullable = false)
    private String name;
    @Column(nullable = false)
    private String city;
    @Column(nullable = false)
    private String location;
    @Column(nullable = false)
    private String longitude;
    @Column(nullable = false)
    private String latitude;
    @OneToMany(mappedBy = "university")
    private List<Doctor> doctors;
}
