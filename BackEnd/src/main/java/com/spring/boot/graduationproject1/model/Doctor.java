package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class Doctor {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false)
    private String firstName;
    @Column(nullable = false)
    private String lastName;
    @Column(nullable = false)
    private String email;
    @Column(nullable = false,unique = true)
    private String password;
   @Column(nullable = false)
    private String studyYear;
   @Column(nullable = false ,unique = true)
    private String phoneNumber;
   @Column(nullable = false)
    private String cityName;
   @Column(nullable = false)
    private String universityName;
   @Column(nullable = false)
   private String categoryName;
    @ManyToOne
    @JoinColumn(name = "university_id", nullable = false)
    private University university;
    @ManyToOne
    @JoinColumn(name = "role_id", nullable = false)
    private Role role;
    @ManyToOne
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;
    @ManyToOne
    @JoinColumn(name = "city_id", nullable = false)
    private City city;

}
