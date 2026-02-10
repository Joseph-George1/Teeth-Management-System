package com.spring.boot.graduationproject1.config.jwt;

import com.spring.boot.graduationproject1.dto.DoctorDto;
import com.spring.boot.graduationproject1.dto.TokenUserDto;
import com.spring.boot.graduationproject1.helper.JwtToken;
import com.spring.boot.graduationproject1.model.Doctor;
import com.spring.boot.graduationproject1.service.DoctorService;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtBuilder;
import io.jsonwebtoken.JwtParser;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.transaction.SystemException;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.time.Duration;
import java.util.Date;
import java.util.Map;
import java.util.Objects;

@Component
public class TokenHandler {

    private String secret;
    private Duration time;
    private JwtBuilder jwtBuilder;
    private JwtParser jwtParser;
    private DoctorService doctorService;


    public TokenHandler(JwtToken jwtToken, DoctorService doctorService) {
        this.doctorService = doctorService;
        this.secret = jwtToken.getSecret();
        this.time = jwtToken.getTime();

        Key key= Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));

        jwtBuilder= Jwts.builder().signWith(key);
        jwtParser= Jwts.parserBuilder().setSigningKey(key).build();
    }

    public String createToken(String email, String role, Map<String, Object> extraClaims) {

        Date issueDate = new Date();
        Date expiryDate = Date.from(issueDate.toInstant().plus(time));

        JwtBuilder builder = Jwts.builder()
                .setSubject(email)
                .setIssuedAt(issueDate)
                .setExpiration(expiryDate)
                .claim("role", role);

        if (extraClaims != null) {
            extraClaims.forEach(builder::claim);
        }

        return builder
                .signWith(Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8)))
                .compact();
    }

    public TokenUserDto validateToken(String token) {

        Claims claims = jwtParser.parseClaimsJws(token).getBody();

        if (claims.getExpiration().before(new Date())) {
            return null;
        }

        TokenUserDto user = new TokenUserDto();
        user.setEmail(claims.getSubject());
        user.setRole(claims.get("role", String.class));

        return user;
    }
}
