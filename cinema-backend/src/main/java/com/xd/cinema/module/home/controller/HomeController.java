package com.xd.cinema.module.home.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.module.movie.entity.Movie;
import com.xd.cinema.module.movie.mapper.MovieMapper;
import com.xd.cinema.module.order.mapper.OrderMapper;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/home")
@RequiredArgsConstructor
public class HomeController {

  private final MovieMapper movieMapper;
  private final OrderMapper orderMapper;

  @GetMapping
  public ApiResult<Map<String, Object>> home() {
    Map<String, Object> map = new LinkedHashMap<>();
    List<Movie> hot = movieMapper.listByStatus(1, null);
    List<Movie> upcoming = movieMapper.listByStatus(0, null);
    map.put("hot", hot == null ? List.of() : hot.stream().limit(8).toList());
    map.put("upcoming", upcoming == null ? List.of() : upcoming.stream().limit(8).toList());
    map.put("topBoxOffice", movieMapper.topBoxOffice(10));
    map.put("todayBoxOffice", orderMapper.sumTodayBoxOffice());
    return ApiResult.ok(map);
  }
}

