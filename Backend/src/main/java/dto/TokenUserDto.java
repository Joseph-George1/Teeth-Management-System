/*
 * Copyright (c) 2026 Muhammad Ashraf Tawfik Elkateb
 * GitHub: https://github.com/MuhammamdElKateb
 */
package com.spring.boot.graduationproject1.dto;


import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class TokenUserDto {
    private String email;
    private String role;
}
