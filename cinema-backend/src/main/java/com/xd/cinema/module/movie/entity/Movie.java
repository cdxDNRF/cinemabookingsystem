package com.xd.cinema.module.movie.entity;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.Data;

@Data
public class Movie {
  private Long id;
  private String name;
  private String nameEn;
  private String posterUrl;
  private String region;
  private Integer year;
  private String language;
  private LocalDate releaseDate;
  private Integer durationMin;
  private String intro;
  private String trailerJson;
  private Integer status;
  private BigDecimal totalBoxOffice;
  private BigDecimal ratingAvg;
  private Integer ratingCount;
  private LocalDateTime createdTime;
  private LocalDateTime updatedTime;
}

