package com.xd.cinema.module.showing.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.exception.BizException;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.common.security.UserContext;
import com.xd.cinema.module.cinema.entity.CinemaAdmin;
import com.xd.cinema.module.cinema.mapper.CinemaAdminMapper;
import com.xd.cinema.module.showing.dto.ShowingApplyRequest;
import com.xd.cinema.module.showing.service.ShowingService;
import com.xd.cinema.module.showing.vo.ShowingItemVO;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/cinema-admin/showings")
@RequireRole(RoleType.CINEMA_ADMIN)
@RequiredArgsConstructor
public class CinemaAdminShowingController {

  private final CinemaAdminMapper cinemaAdminMapper;
  private final ShowingService showingService;

  @GetMapping
  public ApiResult<List<ShowingItemVO>> listMy() {
    CinemaAdmin ca = cinemaAdminMapper.findById(UserContext.get().getId());
    if (ca == null || ca.getCinemaId() == null) {
      throw new BizException(400, "未绑定影院");
    }
    return ApiResult.ok(showingService.listMyCinemaShowings(ca.getCinemaId()));
  }

  @PostMapping
  public ApiResult<Long> apply(@Valid @RequestBody ShowingApplyRequest req) {
    CinemaAdmin ca = cinemaAdminMapper.findById(UserContext.get().getId());
    if (ca == null || ca.getCinemaId() == null) {
      throw new BizException(400, "未绑定影院");
    }
    return ApiResult.ok(showingService.applyShowing(ca.getId(), ca.getCinemaId(), req));
  }
}

