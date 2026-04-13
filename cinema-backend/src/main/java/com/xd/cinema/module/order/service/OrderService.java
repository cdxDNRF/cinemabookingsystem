package com.xd.cinema.module.order.service;

import com.xd.cinema.module.order.dto.OrderCreateRequest;
import com.xd.cinema.module.order.vo.OrderCreateVO;
import com.xd.cinema.module.order.vo.OrderDetailVO;
import com.xd.cinema.module.order.vo.SeatMapVO;
import java.util.List;

public interface OrderService {

  SeatMapVO seatMap(Long showingId);

  OrderCreateVO create(Long userId, OrderCreateRequest req);

  void pay(Long userId, String orderNo);

  void cancel(Long userId, String orderNo);

  List<OrderDetailVO> listMyOrders(Long userId, String orderNo);

  List<OrderDetailVO> listAllOrders(Long cinemaId);
}

