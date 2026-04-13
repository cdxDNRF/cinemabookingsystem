package com.xd.cinema.module.movie.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import lombok.Data;

@Data
public class MovieUpsertRequest {
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
  private List<Long> typeIds;
}

