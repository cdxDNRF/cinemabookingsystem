package com.xd.cinema.module.cinema.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.module.cinema.entity.Hall;
import com.xd.cinema.module.cinema.mapper.HallMapper;
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
@RequestMapping("/api/admin/halls")
@RequireRole(RoleType.ADMIN)
@RequiredArgsConstructor
public class AdminHallController {

  private final HallMapper hallMapper;

  @GetMapping
  public ApiResult<List<Hall>> listAll() {
    return ApiResult.ok(hallMapper.listAll());
  }

  @PostMapping
  public ApiResult<Void> upsert(@RequestBody Hall hall) {
    if (hall.getSeatRows() == null) {
      hall.setSeatRows(8);
    }
    if (hall.getSeatCols() == null) {
      hall.setSeatCols(8);
    }
    if (hall.getStatus() == null) {
      hall.setStatus(1);
    }
    if (hall.getId() == null) {
      hallMapper.insert(hall);
    } else {
      hallMapper.update(hall);
    }
    return ApiResult.ok();
  }

  @DeleteMapping("/{id}")
  public ApiResult<Void> delete(@PathVariable Long id) {
    hallMapper.delete(id);
    return ApiResult.ok();
  }
}

