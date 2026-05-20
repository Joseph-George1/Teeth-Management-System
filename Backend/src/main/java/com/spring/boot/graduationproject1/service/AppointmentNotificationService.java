package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.model.Appointments;

public interface AppointmentNotificationService {
    void notifyAppointmentCreated(Appointments appointment);
    void notifyAppointmentApproved(Appointments appointment);
    void notifyAppointmentCancelled(Appointments appointment);
    void notifyAppointmentDone(Appointments appointment);
}
