package com.xd.cinema.module.profile.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.common.security.UserContext;
import com.xd.cinema.common.util.PasswordUtil;
import com.xd.cinema.module.cinema.entity.CinemaAdmin;
import com.xd.cinema.module.cinema.mapper.CinemaAdminMapper;
import com.xd.cinema.module.profile.dto.ChangePasswordRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/cinema-admin")
@RequireRole(RoleType.CINEMA_ADMIN)
@RequiredArgsConstructor
public class CinemaAdminProfileController {

  private final CinemaAdminMapper cinemaAdminMapper;

  @GetMapping("/me")
  public ApiResult<CinemaAdmin> me() {
    return ApiResult.ok(cinemaAdminMapper.findById(UserContext.get().getId()));
  }

  @PostMapping("/profile")
  public ApiResult<Void> updateProfile(@RequestBody CinemaAdmin ca) {
    ca.setId(UserContext.get().getId());
    cinemaAdminMapper.updateProfile(ca);
    return ApiResult.ok();
  }

  @PostMapping("/password")
  public ApiResult<Void> changePassword(@Valid @RequestBody ChangePasswordRequest req) {
    CinemaAdmin ca = cinemaAdminMapper.findById(UserContext.get().getId());
    if (ca == null || !PasswordUtil.matches(req.getOldPassword(), ca.getPasswordHash())) {
      return ApiResult.fail(400, "原密码错误");
    }
    cinemaAdminMapper.updatePassword(ca.getId(), PasswordUtil.hash(req.getNewPassword()));
    return ApiResult.ok();
  }
}

