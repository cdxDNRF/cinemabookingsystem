package com.xd.cinema.module.order.vo;

import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class OrderCreateVO {
  private String orderNo;
  private LocalDateTime lockExpireTime;
  private String statusText;
}

