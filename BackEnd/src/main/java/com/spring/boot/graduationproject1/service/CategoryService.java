package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.dto.CategoryDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface CategoryService {

    List<CategoryDto> getCategories();
}
