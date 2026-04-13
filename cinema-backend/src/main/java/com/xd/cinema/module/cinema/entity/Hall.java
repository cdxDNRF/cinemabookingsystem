package com.xd.cinema.module.cinema.entity;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class Hall {
  private Long id;
  private Long cinemaId;
  private String name;
  private Integer seatRows;
  private Integer seatCols;
  private Integer status;
  private LocalDateTime createdTime;
  private LocalDateTime updatedTime;
}

