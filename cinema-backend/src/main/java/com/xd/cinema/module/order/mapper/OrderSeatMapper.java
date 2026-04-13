package com.xd.cinema.module.order.mapper;

import com.xd.cinema.module.order.entity.OrderSeat;
import java.util.List;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface OrderSeatMapper {

  @Insert("insert into t_order_seat(order_id,seat_row,seat_col) values(#{orderId},#{seatRow},#{seatCol})")
  int insert(OrderSeat seat);

  @Select("select * from t_order_seat where order_id=#{orderId} order by seat_row asc, seat_col asc")
  List<OrderSeat> listByOrderId(Long orderId);

  @Select("select os.* from t_order_seat os join t_order o on o.id=os.order_id where o.showing_id=#{showingId}")
  List<OrderSeat> listByShowingId(Long showingId);

  @Select("select os.* from t_order_seat os join t_order o on o.id=os.order_id where o.showing_id=#{showingId} and (o.status in (1,2) or (o.status=0 and o.lock_expire_time>now()))")
  List<OrderSeat> listOccupiedByShowingId(Long showingId);

  @Select("select count(1) from t_order_seat os join t_order o on o.id=os.order_id where o.showing_id=#{showingId} and os.seat_row=#{seatRow} and os.seat_col=#{seatCol} and (o.status in (1,2) or (o.status=0 and o.lock_expire_time>now()))")
  int countOccupied(@Param("showingId") Long showingId, @Param("seatRow") int seatRow, @Param("seatCol") int seatCol);
}

