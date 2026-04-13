package com.xd.cinema.module.movie.entity;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class MovieType {
  private Long id;
  private String name;
  private Integer sortNo;
  private Integer status;
  private LocalDateTime createdTime;
  private LocalDateTime updatedTime;
}

