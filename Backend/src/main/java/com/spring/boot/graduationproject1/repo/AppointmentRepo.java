package com.spring.boot.graduationproject1.repo;

import com.spring.boot.graduationproject1.model.Appointments;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AppointmentRepo extends JpaRepository<Appointments, Long> {
}
