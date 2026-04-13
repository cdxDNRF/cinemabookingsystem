package com.xd.cinema.auth.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RegisterUserRequest {

  @NotBlank(message = "请输入用户名")
  private String username;

  @NotBlank(message = "请输入密码")
  private String password;

  @NotBlank(message = "请输入昵称")
  private String nickname;

  private String phone;
}

