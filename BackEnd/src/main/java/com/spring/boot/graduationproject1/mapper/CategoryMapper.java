package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.CategoryDto;
import com.spring.boot.graduationproject1.model.Category;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface CategoryMapper {
    CategoryDto toDto(Category category);
    Category toEntity(CategoryDto categoryDto);
    List<CategoryDto> toListDto(List<Category> categories);
    List<Category> toListEntity(List<CategoryDto> categoryDtos);
}
