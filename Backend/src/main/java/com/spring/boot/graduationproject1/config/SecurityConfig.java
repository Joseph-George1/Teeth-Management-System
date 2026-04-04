package com.spring.boot.graduationproject1.config;

import com.spring.boot.graduationproject1.config.filter.AuthFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Lazy;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;


@Configuration
@EnableWebSecurity
public class SecurityConfig {



    private @Lazy AuthFilter authFilter;

    public SecurityConfig(AuthFilter authFilter) {
        this.authFilter = authFilter;

    }

    @Bean
    public static PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http

                .csrf(csrf -> csrf.disable())
                .cors(cors -> {})
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/auth/**").permitAll()
                        .requestMatchers(HttpMethod.GET,
                                "/api/doctor/getDoctorsBy**",
                                "/api/category/**",
                                "/api/cities/**",
                                "/api/university/**",
                                "/api/request/getRequestByCategoryId")
                        .permitAll()
                        .requestMatchers(HttpMethod.POST,"/api/appointment/createAppointment/**").permitAll()
                        .requestMatchers(HttpMethod.GET,"/api/doctor/getDoctors").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.GET,"/api/doctor/getDoctorById" ).hasAnyRole("ADMIN","DOCTOR")
                        .requestMatchers(HttpMethod.PUT,"/api/doctor/updateDoctor").hasAnyRole("DOCTOR","ADMIN")
                        .requestMatchers(HttpMethod.DELETE,"/api/doctor/deleteDoctor").hasAnyRole("DOCTOR","ADMIN")
                        .requestMatchers(HttpMethod.DELETE,"/api/doctor/deleteByDoctorAdmin").hasAnyRole("ADMIN")
                        .requestMatchers(HttpMethod.GET,"/api/request/getRequestsByDoctorId").hasAnyRole("ADMIN","DOCTOR")
                        .requestMatchers(HttpMethod.GET,"/api/request/getAllRequests").hasAnyRole("ADMIN")
                        .requestMatchers(HttpMethod.POST,"/api/request/createRequest").hasAnyRole("DOCTOR","ADMIN")
                        .requestMatchers(HttpMethod.DELETE,"/api/request/deleteRequest").hasAnyRole("DOCTOR","ADMIN")
                        .requestMatchers(HttpMethod.GET,"/api/appointment/getAllAppointments").hasAnyRole("ADMIN")
                        .requestMatchers(HttpMethod.GET,"/api/appointment/getAppointmentsByDoctorId").hasAnyRole("ADMIN","DOCTOR")
                        .requestMatchers(HttpMethod.GET,"/api/appointment/getAppointmentById").hasAnyRole("ADMIN")
                        .requestMatchers(HttpMethod.GET,"/api/appointment/getAppointmentsByDoctorId").hasAnyRole("DOCTOR","ADMIN")
                        .requestMatchers(HttpMethod.GET,"/api/appointment/getApprovedAndDone").hasAnyRole("ADMIN","DOCTOR")
                        .requestMatchers(HttpMethod.GET,"/api/appointment/getApproved").hasAnyRole("ADMIN","DOCTOR")
                        .requestMatchers(HttpMethod.GET,"/api/appointment/getDone").hasAnyRole("ADMIN","DOCTOR")
                        .anyRequest().authenticated()
                )
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .addFilterBefore(authFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }




}