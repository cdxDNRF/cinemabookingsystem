package com.xd.cinema.module.showing.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.module.showing.service.ShowingService;
import com.xd.cinema.module.showing.vo.ShowingItemVO;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/showings")
@RequiredArgsConstructor
public class ShowingPublicController {

  private final ShowingService showingService;

  @GetMapping
  public ApiResult<List<ShowingItemVO>> listByCinema(@RequestParam Long cinemaId, @RequestParam(required = false) Long movieId) {
    return ApiResult.ok(showingService.listCinemaShowingsForUser(cinemaId, movieId));
  }
}

