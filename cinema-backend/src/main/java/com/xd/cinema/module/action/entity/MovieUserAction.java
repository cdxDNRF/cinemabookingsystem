package com.xd.cinema.module.action.entity;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class MovieUserAction {
  private Long id;
  private Long userId;
  private Long movieId;
  private Integer isFavorite;
  private LocalDateTime favoriteTime;
  private Integer score;
  private LocalDateTime scoreTime;
  private String content;
  private LocalDateTime createdTime;
  private LocalDateTime updatedTime;
}
