package com.xd.cinema.module.order.mapper;

import com.xd.cinema.module.order.entity.Order;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface OrderMapper {
  Order findById(Long id);

  Order findByOrderNo(String orderNo);

  int insert(Order order);

  int updateStatusPay(@Param("id") Long id, @Param("payTime") String payTime);

  int updateStatusCancel(@Param("id") Long id, @Param("status") int status, @Param("cancelTime") String cancelTime);

  List<Order> listByUser(@Param("userId") Long userId, @Param("orderNo") String orderNo);

  List<Order> listAdmin(@Param("cinemaId") Long cinemaId);

  List<Long> listConflictOrderIds(@Param("showingId") Long showingId, @Param("seats") List<SeatCoord> seats);

  List<Long> listExpiredLockOrderIds();

  int markTimeoutCanceled(@Param("id") Long id, @Param("cancelTime") String cancelTime);

  List<BoxOfficeDayRow> sumBoxOfficeLast7Days();

  BigDecimal sumTodayBoxOffice();

  class SeatCoord {
    public Integer row;
    public Integer col;

    public SeatCoord() {
    }

    public SeatCoord(Integer row, Integer col) {
      this.row = row;
      this.col = col;
    }
  }

  class BoxOfficeDayRow {
    public LocalDate day;
    public BigDecimal amount;
  }
}

