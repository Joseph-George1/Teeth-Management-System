/*
 * Copyright (c) 2026 Muhammad Ashraf Tawfik Elkateb
 * GitHub: https://github.com/MuhammamdElKateb
 */
package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.model.User;

public interface NotificationService {
    public void notifyUser(User user, String title, String body);
}
