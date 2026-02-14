package com.spring.boot.graduationproject1.helper;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ExceptionResponse {
    private String messageAr;
    private String messageEn;


    public ExceptionResponse(String messageEn){
        this.messageEn = messageEn;
    }
}
