package com.xd.cinema.module.cinema.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.module.cinema.entity.Cinema;
import com.xd.cinema.module.cinema.service.CinemaService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/cinemas")
@RequiredArgsConstructor
public class CinemaPublicController {

  private final CinemaService cinemaService;

  @GetMapping
  public ApiResult<List<Cinema>> list() {
    return ApiResult.ok(cinemaService.listEnabledCinemas());
  }
}

