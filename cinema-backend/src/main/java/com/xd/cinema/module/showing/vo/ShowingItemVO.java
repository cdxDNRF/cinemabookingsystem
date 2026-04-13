package com.xd.cinema.module.showing.vo;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.Data;

@Data
public class ShowingItemVO {
  private Long id;
  private Long cinemaId;
  private String cinemaName;
  private Long hallId;
  private String hallName;
  private Long movieId;
  private String movieName;
  private String moviePosterUrl;
  private LocalDateTime startTime;
  private LocalDateTime endTime;
  private BigDecimal ticketPrice;
  private Integer auditStatus;
}

