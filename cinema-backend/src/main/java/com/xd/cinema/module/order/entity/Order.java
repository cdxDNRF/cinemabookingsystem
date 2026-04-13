package com.xd.cinema.module.order.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.Data;

@Data
public class Order {
  private Long id;
  private String orderNo;
  private Long userId;
  private Long showingId;
  private Long cinemaId;
  private Long hallId;
  private Long movieId;
  private Integer seatCount;
  private BigDecimal totalAmount;
  private Integer status;
  private LocalDateTime lockExpireTime;
  private LocalDateTime payTime;
  private LocalDateTime cancelTime;
  private LocalDateTime createdTime;
  private LocalDateTime updatedTime;
}

