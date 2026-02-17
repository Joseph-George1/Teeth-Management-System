package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.dto.CategoryDto;
import com.spring.boot.graduationproject1.mapper.CategoryMapper;
import com.spring.boot.graduationproject1.repo.CategoryRepo;
import com.spring.boot.graduationproject1.service.CategoryService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoryServiceImpl implements CategoryService {
    private final CategoryRepo categoryRepo;
    private final CategoryMapper categoryMapper;

    public CategoryServiceImpl(CategoryRepo categoryRepo, CategoryMapper categoryMapper) {
        this.categoryMapper = categoryMapper;
        this.categoryRepo = categoryRepo;
    }

    @Override
    public List<CategoryDto> getCategories() {
        return categoryMapper.toListDto(categoryRepo.findAll());
    }
}
