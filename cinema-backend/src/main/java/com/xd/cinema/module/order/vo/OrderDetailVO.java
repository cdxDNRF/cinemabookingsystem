package com.xd.cinema.module.order.vo;

import com.xd.cinema.module.order.entity.Order;
import com.xd.cinema.module.order.entity.OrderSeat;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class OrderDetailVO {
  private Order order;
  private List<OrderSeat> seats;
}

