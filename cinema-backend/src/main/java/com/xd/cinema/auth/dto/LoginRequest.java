package com.xd.cinema.auth.dto;

import com.xd.cinema.common.enums.RoleType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class LoginRequest {

  @NotBlank(message = "请输入用户名")
  private String username;

  @NotBlank(message = "请输入密码")
  private String password;

  @NotNull(message = "请选择角色")
  private RoleType role;
}

