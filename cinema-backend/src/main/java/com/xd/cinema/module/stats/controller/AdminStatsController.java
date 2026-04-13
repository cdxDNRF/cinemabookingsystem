package com.xd.cinema.module.stats.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.module.order.mapper.OrderMapper;
import com.xd.cinema.module.stats.mapper.StatsMapper;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/stats")
@RequireRole(RoleType.ADMIN)
@RequiredArgsConstructor
public class AdminStatsController {

  private final OrderMapper orderMapper;
  private final StatsMapper statsMapper;

  @GetMapping("/overview")
  public ApiResult<Map<String, Object>> overview() {
    Map<String, Object> map = new LinkedHashMap<>();
    map.put("movieCount", statsMapper.countMovies());
    map.put("cinemaCount", statsMapper.countCinemas());
    map.put("todayBoxOffice", orderMapper.sumTodayBoxOffice());
    map.put("totalBoxOffice", statsMapper.sumTotalBoxOffice());
    return ApiResult.ok(map);
  }

  @GetMapping("/box-office-last7days")
  public ApiResult<Map<String, Object>> boxOfficeLast7Days() {
    List<OrderMapper.BoxOfficeDayRow> rows = orderMapper.sumBoxOfficeLast7Days();
    Map<LocalDate, BigDecimal> dayAmount = new LinkedHashMap<>();
    LocalDate start = LocalDate.now().minusDays(6);
    for (int i = 0; i < 7; i++) {
      dayAmount.put(start.plusDays(i), BigDecimal.ZERO);
    }
    if (rows != null) {
      for (OrderMapper.BoxOfficeDayRow r : rows) {
        if (r != null && r.day != null && r.amount != null && dayAmount.containsKey(r.day)) {
          dayAmount.put(r.day, r.amount);
        }
      }
    }
    List<String> x = new ArrayList<>();
    List<BigDecimal> y = new ArrayList<>();
    for (Map.Entry<LocalDate, BigDecimal> e : dayAmount.entrySet()) {
      x.add(String.valueOf(e.getKey()));
      y.add(e.getValue());
    }
    Map<String, Object> res = new LinkedHashMap<>();
    res.put("x", x);
    res.put("y", y);
    return ApiResult.ok(res);
  }

  @GetMapping("/type-count")
  public ApiResult<List<StatsMapper.TypeCountRow>> typeCount() {
    return ApiResult.ok(statsMapper.typeCount());
  }

  @GetMapping("/type-box-office")
  public ApiResult<List<StatsMapper.TypeBoxOfficeRow>> typeBoxOffice() {
    return ApiResult.ok(statsMapper.typeBoxOffice());
  }
}

