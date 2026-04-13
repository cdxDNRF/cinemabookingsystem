package com.xd.cinema.module.profile.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.common.security.UserContext;
import com.xd.cinema.common.util.PasswordUtil;
import com.xd.cinema.module.profile.dto.ChangePasswordRequest;
import com.xd.cinema.module.user.entity.User;
import com.xd.cinema.module.user.mapper.UserMapper;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/user")
@RequireRole(RoleType.USER)
@RequiredArgsConstructor
public class UserProfileController {

  private final UserMapper userMapper;

  @GetMapping("/me")
  public ApiResult<User> me() {
    return ApiResult.ok(userMapper.findById(UserContext.get().getId()));
  }

  @PostMapping("/profile")
  public ApiResult<Void> updateProfile(@RequestBody User user) {
    user.setId(UserContext.get().getId());
    userMapper.updateProfile(user);
    return ApiResult.ok();
  }

  @PostMapping("/password")
  public ApiResult<Void> changePassword(@Valid @RequestBody ChangePasswordRequest req) {
    User user = userMapper.findById(UserContext.get().getId());
    if (user == null || !PasswordUtil.matches(req.getOldPassword(), user.getPasswordHash())) {
      return ApiResult.fail(400, "原密码错误");
    }
    userMapper.updatePassword(user.getId(), PasswordUtil.hash(req.getNewPassword()));
    return ApiResult.ok();
  }
}

