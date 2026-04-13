package com.xd.cinema.module.showing.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.Data;

@Data
public class Showing {
  private Long id;
  private Long cinemaId;
  private Long hallId;
  private Long movieId;
  private LocalDateTime startTime;
  private LocalDateTime endTime;
  private BigDecimal ticketPrice;
  private Long submitterCinemaAdminId;
  private Integer auditStatus;
  private Long auditedByAdminId;
  private LocalDateTime auditedTime;
  private String auditReason;
  private LocalDateTime createdTime;
  private LocalDateTime updatedTime;
}

