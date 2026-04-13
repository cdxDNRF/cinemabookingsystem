package com.xd.cinema.module.movie.entity;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class MovieStaff {
  private Long id;
  private Long movieId;
  private Integer roleType;
  private String name;
  private String avatarUrl;
  private Integer sortNo;
  private LocalDateTime createdTime;
  private LocalDateTime updatedTime;
}

