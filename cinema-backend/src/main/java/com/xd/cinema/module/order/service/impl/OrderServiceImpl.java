package com.xd.cinema.module.order.service.impl;

import cn.hutool.core.util.IdUtil;
import com.xd.cinema.common.enums.OrderStatus;
import com.xd.cinema.common.exception.BizException;
import com.xd.cinema.module.cinema.entity.Hall;
import com.xd.cinema.module.cinema.mapper.HallMapper;
import com.xd.cinema.module.movie.mapper.MovieMapper;
import com.xd.cinema.module.order.dto.OrderCreateRequest;
import com.xd.cinema.module.order.dto.SeatCoord;
import com.xd.cinema.module.order.entity.Order;
import com.xd.cinema.module.order.entity.OrderSeat;
import com.xd.cinema.module.order.mapper.OrderMapper;
import com.xd.cinema.module.order.mapper.OrderSeatMapper;
import com.xd.cinema.module.order.service.OrderService;
import com.xd.cinema.module.order.vo.OrderCreateVO;
import com.xd.cinema.module.order.vo.OrderDetailVO;
import com.xd.cinema.module.order.vo.SeatMapVO;
import com.xd.cinema.module.showing.entity.Showing;
import com.xd.cinema.module.showing.mapper.ShowingMapper;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

  private final ShowingMapper showingMapper;
  private final HallMapper hallMapper;
  private final OrderMapper orderMapper;
  private final OrderSeatMapper orderSeatMapper;
  private final MovieMapper movieMapper;

  @Value("${cinema.order.lock-minutes:10}")
  private int lockMinutes;

  @Override
  public SeatMapVO seatMap(Long showingId) {
    Showing showing = showingMapper.findById(showingId);
    if (showing == null || showing.getAuditStatus() == null || showing.getAuditStatus() != 1) {
      throw new BizException(404, "场次不存在");
    }
    Hall hall = hallMapper.findById(showing.getHallId());
    if (hall == null) {
      throw new BizException(404, "影厅不存在");
    }
    int rows = hall.getSeatRows() == null ? 8 : hall.getSeatRows();
    int cols = hall.getSeatCols() == null ? 8 : hall.getSeatCols();
    boolean[][] occupied = new boolean[rows + 1][cols + 1];
    List<OrderSeat> seats = orderSeatMapper.listOccupiedByShowingId(showingId);
    for (OrderSeat s : seats) {
      if (s.getSeatRow() != null && s.getSeatCol() != null && s.getSeatRow() >= 1 && s.getSeatRow() <= rows && s.getSeatCol() >= 1 && s.getSeatCol() <= cols) {
        occupied[s.getSeatRow()][s.getSeatCol()] = true;
      }
    }
    List<List<Integer>> grid = new ArrayList<>();
    for (int r = 1; r <= rows; r++) {
      List<Integer> line = new ArrayList<>();
      for (int c = 1; c <= cols; c++) {
        line.add(occupied[r][c] ? 1 : 0);
      }
      grid.add(line);
    }
    return new SeatMapVO(rows, cols, grid);
  }

  @Override
  @Transactional
  public OrderCreateVO create(Long userId, OrderCreateRequest req) {
    Showing showing = showingMapper.findById(req.getShowingId());
    if (showing == null || showing.getAuditStatus() == null || showing.getAuditStatus() != 1) {
      throw new BizException(404, "场次不存在");
    }
    Hall hall = hallMapper.findById(showing.getHallId());
    if (hall == null) {
      throw new BizException(404, "影厅不存在");
    }
    int rows = hall.getSeatRows() == null ? 8 : hall.getSeatRows();
    int cols = hall.getSeatCols() == null ? 8 : hall.getSeatCols();
    if (req.getSeats().size() > rows * cols) {
      throw new BizException(400, "座位数量不合法");
    }
    Set<String> uniq = new HashSet<>();
    for (SeatCoord s : req.getSeats()) {
      if (s.getRow() == null || s.getCol() == null) {
        throw new BizException(400, "座位参数错误");
      }
      if (s.getRow() < 1 || s.getRow() > rows || s.getCol() < 1 || s.getCol() > cols) {
        throw new BizException(400, "座位超出范围");
      }
      String key = s.getRow() + "-" + s.getCol();
      if (!uniq.add(key)) {
        throw new BizException(400, "存在重复座位");
      }
      if (orderSeatMapper.countOccupied(req.getShowingId(), s.getRow(), s.getCol()) > 0) {
        throw new BizException(400, "所选座位已被占用");
      }
    }

    BigDecimal totalAmount = showing.getTicketPrice().multiply(BigDecimal.valueOf(req.getSeats().size()));
    String orderNo = IdUtil.getSnowflakeNextIdStr();
    LocalDateTime lockExpire = LocalDateTime.now().plusMinutes(lockMinutes);
    Order order = new Order();
    order.setOrderNo(orderNo);
    order.setUserId(userId);
    order.setShowingId(req.getShowingId());
    order.setCinemaId(showing.getCinemaId());
    order.setHallId(showing.getHallId());
    order.setMovieId(showing.getMovieId());
    order.setSeatCount(req.getSeats().size());
    order.setTotalAmount(totalAmount);
    order.setStatus(OrderStatus.PENDING_PAY.getCode());
    order.setLockExpireTime(lockExpire);
    orderMapper.insert(order);
    for (SeatCoord s : req.getSeats()) {
      OrderSeat os = new OrderSeat();
      os.setOrderId(order.getId());
      os.setSeatRow(s.getRow());
      os.setSeatCol(s.getCol());
      orderSeatMapper.insert(os);
    }
    return new OrderCreateVO(orderNo, lockExpire, "待支付");
  }

  @Override
  @Transactional
  public void pay(Long userId, String orderNo) {
    Order order = orderMapper.findByOrderNo(orderNo);
    if (order == null || !userId.equals(order.getUserId())) {
      throw new BizException(404, "订单不存在");
    }
    if (order.getStatus() != OrderStatus.PENDING_PAY.getCode()) {
      throw new BizException(400, "订单状态不支持支付");
    }
    if (order.getLockExpireTime() == null || LocalDateTime.now().isAfter(order.getLockExpireTime())) {
      orderMapper.updateStatusCancel(order.getId(), OrderStatus.TIMEOUT_CANCELED.getCode(), nowStr());
      throw new BizException(400, "锁座已超时，请重新选座");
    }
    int updated = orderMapper.updateStatusPay(order.getId(), nowStr());
    if (updated <= 0) {
      throw new BizException(400, "支付失败");
    }
    movieMapper.incBoxOffice(order.getMovieId(), order.getTotalAmount());
  }

  @Override
  @Transactional
  public void cancel(Long userId, String orderNo) {
    Order order = orderMapper.findByOrderNo(orderNo);
    if (order == null || !userId.equals(order.getUserId())) {
      throw new BizException(404, "订单不存在");
    }
    if (order.getStatus() == OrderStatus.PENDING_PAY.getCode()) {
      orderMapper.updateStatusCancel(order.getId(), OrderStatus.CANCELED.getCode(), nowStr());
      return;
    }
    if (order.getStatus() == OrderStatus.PENDING_TICKET.getCode()) {
      orderMapper.updateStatusCancel(order.getId(), OrderStatus.CANCELED.getCode(), nowStr());
      movieMapper.incBoxOffice(order.getMovieId(), order.getTotalAmount().negate());
      return;
    }
    throw new BizException(400, "订单状态不支持取消");
  }

  @Override
  public List<OrderDetailVO> listMyOrders(Long userId, String orderNo) {
    List<Order> orders = orderMapper.listByUser(userId, orderNo);
    List<OrderDetailVO> list = new ArrayList<>();
    for (Order o : orders) {
      list.add(new OrderDetailVO(o, orderSeatMapper.listByOrderId(o.getId())));
    }
    return list;
  }

  @Override
  public List<OrderDetailVO> listAllOrders(Long cinemaId) {
    List<Order> orders = orderMapper.listAdmin(cinemaId);
    List<OrderDetailVO> list = new ArrayList<>();
    for (Order o : orders) {
      list.add(new OrderDetailVO(o, orderSeatMapper.listByOrderId(o.getId())));
    }
    return list;
  }

  private String nowStr() {
    return LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
  }
}

