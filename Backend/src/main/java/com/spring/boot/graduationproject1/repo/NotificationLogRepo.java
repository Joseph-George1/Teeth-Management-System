package com.spring.boot.graduationproject1.repo;

import com.spring.boot.graduationproject1.model.NotificationLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NotificationLogRepo extends JpaRepository<NotificationLog, Long> {

}
