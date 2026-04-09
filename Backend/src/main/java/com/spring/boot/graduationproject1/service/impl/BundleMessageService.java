package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.helper.ExceptionResponse;
import org.springframework.context.support.ResourceBundleMessageSource;
import org.springframework.stereotype.Component;

import java.util.Locale;

@Component
public class BundleMessageService {

    public static ResourceBundleMessageSource messageSource;

    public BundleMessageService(ResourceBundleMessageSource messageSource){
        this.messageSource = messageSource;
    }

    public static String getBundleMessageAr(String key){
        try {
            return messageSource.getMessage(key, null, new Locale("ar"));
        } catch (Exception e) {
            return messageSource.getMessage("no.static.resource", null, new Locale("ar"));
        }
    }
    public static String getBundleMessageEn(String key){
        try {
            return messageSource.getMessage(key, null, new Locale("en"));
        } catch (Exception e) {
            return messageSource.getMessage("no.static.resource", null, new Locale("en"));
        }
    }
    public static ExceptionResponse getBundleMessage(String key){
        return new ExceptionResponse(

                getBundleMessageAr(key),getBundleMessageEn(key)
        );
    }
}
