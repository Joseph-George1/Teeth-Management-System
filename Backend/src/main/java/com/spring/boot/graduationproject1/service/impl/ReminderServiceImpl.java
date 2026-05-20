package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.model.Appointments;
import com.spring.boot.graduationproject1.model.User;
import com.spring.boot.graduationproject1.repo.AppointmentRepo;
import com.spring.boot.graduationproject1.repo.UserRepo;
import com.spring.boot.graduationproject1.service.NotificationService;
import com.spring.boot.graduationproject1.service.ReminderService;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@EnableScheduling
public class ReminderServiceImpl implements ReminderService {

    private final AppointmentRepo appointmentRepo;
    private final NotificationService notificationService;
    private final UserRepo userRepo;

    public ReminderServiceImpl(AppointmentRepo appointmentRepo, NotificationService notificationService, UserRepo userRepo) {
        this.appointmentRepo = appointmentRepo;
        this.notificationService = notificationService;
        this.userRepo = userRepo;
    }

    @Override
    @Scheduled(fixedRate = 60000)
    public void remind() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime next = now.plusHours(1);

        List<Appointments> list = appointmentRepo.findByAppointmentDateBetween(now, next);

        for (Appointments a : list) {

            User patientUser = userRepo.findByEmail(a.getPatient().getFirstName() + " " + a.getPatient().getLastName())
                    .orElseThrow(() -> new RuntimeException("User not found for patient"));
            notificationService.notifyUser(patientUser, "Reminder", "Appointment soon");


            User doctorUser = userRepo.findByEmail(a.getDoctor().getEmail())
                    .orElseThrow(() -> new RuntimeException("User not found for doctor"));
            notificationService.notifyUser(doctorUser, "Reminder", "Appointment soon");

        }
    }
}
