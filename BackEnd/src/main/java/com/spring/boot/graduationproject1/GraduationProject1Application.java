package com.spring.boot.graduationproject1;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties
@ConfigurationPropertiesScan
public class GraduationProject1Application {

    public static void main(String[] args) {
        SpringApplication.run(GraduationProject1Application.class, args);
    }

}
