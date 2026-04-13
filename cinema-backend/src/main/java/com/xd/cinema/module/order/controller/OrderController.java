package com.xd.cinema.module.order.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.exception.BizException;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.common.security.UserContext;
import com.xd.cinema.module.cinema.entity.CinemaAdmin;
import com.xd.cinema.module.cinema.mapper.CinemaAdminMapper;
import com.xd.cinema.module.order.dto.OrderCreateRequest;
import com.xd.cinema.module.order.service.OrderService;
import com.xd.cinema.module.order.vo.OrderCreateVO;
import com.xd.cinema.module.order.vo.OrderDetailVO;
import com.xd.cinema.module.order.vo.SeatMapVO;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class OrderController {

  private final OrderService orderService;
  private final CinemaAdminMapper cinemaAdminMapper;

  @GetMapping("/showings/{showingId}/seats")
  public ApiResult<SeatMapVO> seatMap(@PathVariable Long showingId) {
    return ApiResult.ok(orderService.seatMap(showingId));
  }

  @PostMapping("/user/orders")
  @RequireRole(RoleType.USER)
  public ApiResult<OrderCreateVO> create(@Valid @RequestBody OrderCreateRequest req) {
    return ApiResult.ok(orderService.create(UserContext.get().getId(), req));
  }

  @PostMapping("/user/orders/{orderNo}/pay")
  @RequireRole(RoleType.USER)
  public ApiResult<Void> pay(@PathVariable String orderNo) {
    orderService.pay(UserContext.get().getId(), orderNo);
    return ApiResult.ok();
  }

  @PostMapping("/user/orders/{orderNo}/cancel")
  @RequireRole(RoleType.USER)
  public ApiResult<Void> cancel(@PathVariable String orderNo) {
    orderService.cancel(UserContext.get().getId(), orderNo);
    return ApiResult.ok();
  }

  @GetMapping("/user/orders")
  @RequireRole(RoleType.USER)
  public ApiResult<List<OrderDetailVO>> listMy(@RequestParam(required = false) String orderNo) {
    return ApiResult.ok(orderService.listMyOrders(UserContext.get().getId(), orderNo));
  }

  @GetMapping("/admin/orders")
  @RequireRole(RoleType.ADMIN)
  public ApiResult<List<OrderDetailVO>> listAll(@RequestParam(required = false) Long cinemaId) {
    return ApiResult.ok(orderService.listAllOrders(cinemaId));
  }

  @GetMapping("/cinema-admin/orders")
  @RequireRole(RoleType.CINEMA_ADMIN)
  public ApiResult<List<OrderDetailVO>> listMyCinemaOrders() {
    CinemaAdmin ca = cinemaAdminMapper.findById(UserContext.get().getId());
    if (ca == null || ca.getCinemaId() == null) {
      throw new BizException(400, "未绑定影院");
    }
    return ApiResult.ok(orderService.listAllOrders(ca.getCinemaId()));
  }
}

