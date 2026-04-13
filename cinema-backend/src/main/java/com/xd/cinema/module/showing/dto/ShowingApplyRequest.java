package com.xd.cinema.module.showing.dto;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.Data;

@Data
public class ShowingApplyRequest {

  @NotNull(message = "请选择电影")
  private Long movieId;

  @NotNull(message = "请选择影厅")
  private Long hallId;

  @NotNull(message = "请选择开始时间")
  private LocalDateTime startTime;

  @NotNull(message = "请选择结束时间")
  private LocalDateTime endTime;

  @NotNull(message = "请输入票价")
  private BigDecimal ticketPrice;
}

