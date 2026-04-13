package com.xd.cinema.module.order.entity;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class OrderSeat {
  private Long id;
  private Long orderId;
  private Integer seatRow;
  private Integer seatCol;
  private LocalDateTime createdTime;
}

