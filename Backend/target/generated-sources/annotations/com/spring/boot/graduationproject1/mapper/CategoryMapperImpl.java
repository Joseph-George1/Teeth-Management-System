package com.spring.boot.graduationproject1.mapper;

import com.spring.boot.graduationproject1.dto.CategoryDto;
import com.spring.boot.graduationproject1.model.Category;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-02-18T10:17:15+0200",
    comments = "version: 1.5.2.Final, compiler: Eclipse JDT (IDE) 3.45.0.v20260128-0750, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class CategoryMapperImpl implements CategoryMapper {

    @Override
    public CategoryDto toDto(Category category) {
        if ( category == null ) {
            return null;
        }

        CategoryDto categoryDto = new CategoryDto();

        categoryDto.setId( category.getId() );
        categoryDto.setName( category.getName() );

        return categoryDto;
    }

    @Override
    public Category toEntity(CategoryDto categoryDto) {
        if ( categoryDto == null ) {
            return null;
        }

        Category category = new Category();

        category.setId( categoryDto.getId() );
        category.setName( categoryDto.getName() );

        return category;
    }

    @Override
    public List<CategoryDto> toListDto(List<Category> categories) {
        if ( categories == null ) {
            return null;
        }

        List<CategoryDto> list = new ArrayList<CategoryDto>( categories.size() );
        for ( Category category : categories ) {
            list.add( toDto( category ) );
        }

        return list;
    }

    @Override
    public List<Category> toListEntity(List<CategoryDto> categoryDtos) {
        if ( categoryDtos == null ) {
            return null;
        }

        List<Category> list = new ArrayList<Category>( categoryDtos.size() );
        for ( CategoryDto categoryDto : categoryDtos ) {
            list.add( toEntity( categoryDto ) );
        }

        return list;
    }
}
