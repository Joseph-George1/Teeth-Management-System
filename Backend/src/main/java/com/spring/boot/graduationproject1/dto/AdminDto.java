/*
 * Copyright (c) 2026 Muhammad Ashraf Tawfik Elkateb
 * GitHub: https://github.com/MuhammamdElKateb
 */
package com.spring.boot.graduationproject1.dto;

import lombok.*;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class AdminDto {

    private long id;
    private String email;
    private String password;

    private RoleDto role;
}
