package com.spring.boot.graduationproject1.controller;

import com.spring.boot.graduationproject1.controller.vm.AuthRequestVm;
import com.spring.boot.graduationproject1.controller.vm.AuthResponseVm;
import com.spring.boot.graduationproject1.dto.SignUpRequest;
import com.spring.boot.graduationproject1.service.AuthService;
import jakarta.transaction.SystemException;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private AuthService authService;
    public AuthController(AuthService authService) {
        this.authService = authService;
    }

@PostMapping("/login/doctor")
    public ResponseEntity<AuthResponseVm>loginDoctor(@RequestBody @Valid AuthRequestVm authRequestVm) throws SystemException {
        return ResponseEntity.ok(authService.loginDoctor(authRequestVm));
}
    @PostMapping("/login/admin")
    public ResponseEntity<AuthResponseVm>loginAdmin(@RequestBody @Valid AuthRequestVm authRequestVm) throws SystemException {
        return ResponseEntity.ok(authService.loginAdmin(authRequestVm));
    }

    @PostMapping("/signup")
    public ResponseEntity<AuthResponseVm> signup(@RequestBody @Valid SignUpRequest request) throws SystemException {
        return ResponseEntity.ok(authService.signup(request));
    }


}
