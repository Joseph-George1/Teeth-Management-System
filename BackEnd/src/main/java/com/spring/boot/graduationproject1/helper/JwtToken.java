package com.spring.boot.graduationproject1.helper;

import lombok.*;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.time.Duration;

@Getter
@Setter
@ConfigurationProperties(prefix = "token")
public class JwtToken {
    private String secret;
    private Duration time;
}
