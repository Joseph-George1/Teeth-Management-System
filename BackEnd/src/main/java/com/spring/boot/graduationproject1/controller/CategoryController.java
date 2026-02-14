package com.spring.boot.graduationproject1.controller;

import com.spring.boot.graduationproject1.dto.CategoryDto;
import com.spring.boot.graduationproject1.service.CategoryService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/category")
public class CategoryController {

    private final CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @GetMapping("/getCategories")
    public ResponseEntity<List<CategoryDto>> getCategories(){
        return ResponseEntity.ok(categoryService.getCategories());
    }
}
