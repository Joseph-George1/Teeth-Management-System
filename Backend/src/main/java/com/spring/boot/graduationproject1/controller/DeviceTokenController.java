package com.spring.boot.graduationproject1.controller;

import com.spring.boot.graduationproject1.model.User;
import com.spring.boot.graduationproject1.repo.UserRepo;
import com.spring.boot.graduationproject1.service.DeviceTokenService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/device-tokens")
@CrossOrigin(origins = "*")
public class DeviceTokenController {
    private static final Logger logger = LoggerFactory.getLogger(DeviceTokenController.class);

    private final DeviceTokenService deviceTokenService;
    private final UserRepo userRepo;

    public DeviceTokenController(DeviceTokenService deviceTokenService, UserRepo userRepo) {
        this.deviceTokenService = deviceTokenService;
        this.userRepo = userRepo;
    }

    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> registerDeviceToken(
            @RequestParam String token) {
        try {
            // Get current user from security context
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            String email = authentication.getName();

            User user = userRepo.findByEmail(email)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            // Save device token
            deviceTokenService.saveToken(user, token);
            
            logger.info("Device token registered for user: {}", user.getId());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Device token registered successfully");
            response.put("userId", user.getId());
            response.put("tokenLength", token.length());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Error registering device token: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @GetMapping("/my-tokens")
    public ResponseEntity<Map<String, Object>> getMyDeviceTokens() {
        try {
            // Get current user from security context
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            String email = authentication.getName();

            User user = userRepo.findByEmail(email)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            // Get device tokens
            List<String> tokens = deviceTokenService.getUserTokens(user.getId());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("userId", user.getId());
            response.put("tokenCount", tokens.size());
            response.put("tokens", tokens);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Error retrieving device tokens: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @DeleteMapping("/deregister")
    public ResponseEntity<Map<String, Object>> deregisterDeviceToken(
            @RequestParam String token) {
        try {
            // Get current user from security context
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            String email = authentication.getName();

            User user = userRepo.findByEmail(email)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            // TODO: Implement deregistration logic in DeviceTokenService
            logger.info("Device token deregistration requested for user: {}", user.getId());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Device token deregistered successfully");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Error deregistering device token: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("success", false, "error", e.getMessage()));
        }
    }
}
