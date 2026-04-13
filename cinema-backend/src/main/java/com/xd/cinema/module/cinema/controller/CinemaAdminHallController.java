package com.xd.cinema.module.cinema.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.exception.BizException;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.common.security.UserContext;
import com.xd.cinema.module.cinema.dto.CinemaApplyRequest;
import com.xd.cinema.module.cinema.entity.CinemaAdmin;
import com.xd.cinema.module.cinema.entity.Hall;
import com.xd.cinema.module.cinema.mapper.CinemaAdminMapper;
import com.xd.cinema.module.cinema.service.CinemaService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/cinema-admin")
@RequireRole(RoleType.CINEMA_ADMIN)
@RequiredArgsConstructor
public class CinemaAdminHallController {

  private final CinemaAdminMapper cinemaAdminMapper;
  private final CinemaService cinemaService;

  @PostMapping("/cinema/apply")
  public ApiResult<Long> applyCinema(@Valid @RequestBody CinemaApplyRequest req) {
    return ApiResult.ok(cinemaService.applyCinemaForCurrentCinemaAdmin(req));
  }

  @GetMapping("/halls")
  public ApiResult<List<Hall>> listMyHalls() {
    CinemaAdmin ca = cinemaAdminMapper.findById(UserContext.get().getId());
    if (ca == null || ca.getCinemaId() == null) {
      throw new BizException(400, "未绑定影院");
    }
    return ApiResult.ok(cinemaService.listMyHalls(ca.getCinemaId()));
  }

  @PostMapping("/halls")
  public ApiResult<Void> upsertHall(@RequestBody Hall hall) {
    CinemaAdmin ca = cinemaAdminMapper.findById(UserContext.get().getId());
    if (ca == null || ca.getCinemaId() == null) {
      throw new BizException(400, "未绑定影院");
    }
    cinemaService.upsertHall(hall, ca.getCinemaId());
    return ApiResult.ok();
  }

  @DeleteMapping("/halls/{id}")
  public ApiResult<Void> deleteHall(@PathVariable Long id) {
    CinemaAdmin ca = cinemaAdminMapper.findById(UserContext.get().getId());
    if (ca == null || ca.getCinemaId() == null) {
      throw new BizException(400, "未绑定影院");
    }
    cinemaService.deleteHall(id, ca.getCinemaId());
    return ApiResult.ok();
  }
}

