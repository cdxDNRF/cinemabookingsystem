package com.xd.cinema.module.admin.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.exception.BizException;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.common.security.UserContext;
import com.xd.cinema.common.util.PasswordUtil;
import com.xd.cinema.module.admin.entity.Admin;
import com.xd.cinema.module.admin.mapper.AdminMapper;
import com.xd.cinema.module.cinema.entity.CinemaAdmin;
import com.xd.cinema.module.cinema.mapper.CinemaAdminMapper;
import com.xd.cinema.module.user.entity.User;
import com.xd.cinema.module.user.mapper.UserMapper;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import java.util.List;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/manage")
@RequireRole(RoleType.ADMIN)
@RequiredArgsConstructor
public class AdminUserManageController {

  private final UserMapper userMapper;
  private final AdminMapper adminMapper;
  private final CinemaAdminMapper cinemaAdminMapper;

  @GetMapping("/users")
  public ApiResult<List<User>> users() {
    return ApiResult.ok(userMapper.listAll());
  }

  @PostMapping("/users/{id}/status/{status}")
  public ApiResult<Void> userStatus(@PathVariable Long id, @PathVariable int status) {
    userMapper.updateStatus(id, status);
    return ApiResult.ok();
  }

  @GetMapping("/admins")
  public ApiResult<List<Admin>> admins() {
    return ApiResult.ok(adminMapper.listAll());
  }

  @PostMapping("/admins")
  public ApiResult<Void> createAdmin(@Valid @RequestBody CreateAdminRequest req) {
    if (adminMapper.findByUsername(req.getUsername()) != null) {
      throw new BizException(400, "用户名已存在");
    }
    Admin a = new Admin();
    a.setUsername(req.getUsername());
    a.setPasswordHash(PasswordUtil.hash(req.getPassword()));
    a.setNickname(req.getNickname());
    a.setStatus(1);
    adminMapper.insert(a);
    return ApiResult.ok();
  }

  @PostMapping("/admins/{id}/status/{status}")
  public ApiResult<Void> adminStatus(@PathVariable Long id, @PathVariable int status) {
    adminMapper.updateStatus(id, status);
    return ApiResult.ok();
  }

  @GetMapping("/cinema-admins")
  public ApiResult<List<CinemaAdmin>> cinemaAdmins() {
    return ApiResult.ok(cinemaAdminMapper.listAll());
  }

  @PostMapping("/cinema-admins/{id}/status/{status}")
  public ApiResult<Void> cinemaAdminStatus(@PathVariable Long id, @PathVariable int status) {
    cinemaAdminMapper.updateStatus(id, status);
    return ApiResult.ok();
  }

  @PostMapping("/cinema-admins/{id}/audit")
  public ApiResult<Void> auditCinemaAdmin(@PathVariable Long id, @Valid @RequestBody AuditRequest req) {
    cinemaAdminMapper.audit(id, req.auditStatus, UserContext.get().getId(), req.reason, req.cinemaId);
    return ApiResult.ok();
  }

  @Data
  public static class AuditRequest {
    private Integer auditStatus;
    private String reason;
    private Long cinemaId;
  }

  @Data
  public static class CreateAdminRequest {
    @NotBlank(message = "请输入用户名")
    private String username;

    @NotBlank(message = "请输入密码")
    private String password;

    @NotBlank(message = "请输入昵称")
    private String nickname;
  }
}

