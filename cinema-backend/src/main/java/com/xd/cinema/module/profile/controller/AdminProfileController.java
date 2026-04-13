package com.xd.cinema.module.profile.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.common.security.UserContext;
import com.xd.cinema.common.util.PasswordUtil;
import com.xd.cinema.module.admin.entity.Admin;
import com.xd.cinema.module.admin.mapper.AdminMapper;
import com.xd.cinema.module.profile.dto.ChangePasswordRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin")
@RequireRole(RoleType.ADMIN)
@RequiredArgsConstructor
public class AdminProfileController {

  private final AdminMapper adminMapper;

  @GetMapping("/me")
  public ApiResult<Admin> me() {
    return ApiResult.ok(adminMapper.findById(UserContext.get().getId()));
  }

  @PostMapping("/password")
  public ApiResult<Void> changePassword(@Valid @RequestBody ChangePasswordRequest req) {
    Admin admin = adminMapper.findById(UserContext.get().getId());
    if (admin == null || !PasswordUtil.matches(req.getOldPassword(), admin.getPasswordHash())) {
      return ApiResult.fail(400, "原密码错误");
    }
    adminMapper.updatePassword(admin.getId(), PasswordUtil.hash(req.getNewPassword()));
    return ApiResult.ok();
  }
}

