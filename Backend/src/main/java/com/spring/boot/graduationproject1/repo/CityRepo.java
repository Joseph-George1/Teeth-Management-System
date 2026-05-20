package com.spring.boot.graduationproject1.repo;

import com.spring.boot.graduationproject1.model.City;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CityRepo extends JpaRepository<City, Long> {
    Optional<City> findByName(String name);
}