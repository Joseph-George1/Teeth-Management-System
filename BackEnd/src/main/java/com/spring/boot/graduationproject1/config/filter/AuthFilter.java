package com.spring.boot.graduationproject1.config.filter;

import com.spring.boot.graduationproject1.config.jwt.TokenHandler;
import com.spring.boot.graduationproject1.dto.DoctorDto;
import com.spring.boot.graduationproject1.dto.TokenUserDto;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;
import java.util.Objects;


@Component
public class AuthFilter extends OncePerRequestFilter {


    private TokenHandler tokenHandler;


    public AuthFilter(TokenHandler tokenHandler) {
        this.tokenHandler = tokenHandler;
    }


    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
        String path = request.getServletPath();

        return path.startsWith("/api/auth")
                || (request.getMethod().equals("GET") &&
                (path.startsWith("/api/category")
                        || path.startsWith("/api/cities")
                        || path.startsWith("/api/university")
                        || path.startsWith("/api/doctor/getDoctorsBy")));
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");

        // 🔓 no token → let Spring Security decide
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7);
        TokenUserDto user = tokenHandler.validateToken(token);

        if (user == null) {
            filterChain.doFilter(request, response);
            return;
        }

        List<GrantedAuthority> authorities =
                List.of(new SimpleGrantedAuthority(user.getRole()));

        UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                        user.getEmail(),
                        null,
                        authorities
                );

        SecurityContextHolder.getContext().setAuthentication(authentication);
        filterChain.doFilter(request, response);
    }
}