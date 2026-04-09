package com.spring.boot.graduationproject1.controller;

import com.spring.boot.graduationproject1.dto.FcmTokenDto;
import com.spring.boot.graduationproject1.model.User;
import com.spring.boot.graduationproject1.repo.UserRepo;
import com.spring.boot.graduationproject1.service.DeviceTokenService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/user")
public class UserController {

    private final UserRepo userRepo;
    private final DeviceTokenService tokenService;

    public UserController(UserRepo userRepo, DeviceTokenService tokenService) {
        this.userRepo = userRepo;
        this.tokenService = tokenService;
    }

    @PostMapping("saveToken")
    public ResponseEntity<String> saveToken(@RequestBody FcmTokenDto dto) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).body("JWT token required - Authorization header missing");
        }

        String email = authentication.getName();

        User user = userRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        tokenService.saveToken(user, dto.getToken());

        return ResponseEntity.ok("Token saved successfully");
    }

}
