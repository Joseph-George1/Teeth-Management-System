package com.spring.boot.graduationproject1.repo;

import com.spring.boot.graduationproject1.model.Appointments;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AppointmentRepo extends JpaRepository<Appointments, Long> {
    List<Appointments> findByDoctorId(Long doctorId);
}
