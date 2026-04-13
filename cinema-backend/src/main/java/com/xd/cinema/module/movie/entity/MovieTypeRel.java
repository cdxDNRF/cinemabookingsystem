package com.xd.cinema.module.movie.entity;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class MovieTypeRel {
  private Long id;
  private Long movieId;
  private Long typeId;
  private LocalDateTime createdTime;
}

