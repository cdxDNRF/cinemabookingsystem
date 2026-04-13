package com.xd.cinema.module.order.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import lombok.Data;

@Data
public class OrderCreateRequest {

  @NotNull(message = "缺少场次")
  private Long showingId;

  @NotEmpty(message = "请选择座位")
  private List<SeatCoord> seats;
}

