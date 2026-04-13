package com.xd.cinema.module.cinema.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.module.cinema.entity.Cinema;
import com.xd.cinema.module.cinema.service.CinemaService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/cinemas")
@RequireRole(RoleType.ADMIN)
@RequiredArgsConstructor
public class AdminCinemaController {

  private final CinemaService cinemaService;

  @GetMapping
  public ApiResult<List<Cinema>> listAll() {
    return ApiResult.ok(cinemaService.listAllCinemas());
  }

  @PostMapping
  public ApiResult<Void> upsert(@RequestBody Cinema cinema) {
    cinemaService.upsertCinema(cinema);
    return ApiResult.ok();
  }

  @PostMapping("/{id}/status/{status}")
  public ApiResult<Void> status(@PathVariable Long id, @PathVariable int status) {
    cinemaService.updateCinemaStatus(id, status);
    return ApiResult.ok();
  }
}

