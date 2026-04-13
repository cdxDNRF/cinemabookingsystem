package com.xd.cinema.auth.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RegisterCinemaAdminRequest {

  @NotBlank(message = "请输入用户名")
  private String username;

  @NotBlank(message = "请输入密码")
  private String password;

  @NotBlank(message = "请输入真实姓名")
  private String realName;

  private String idCardNo;
  private String phone;
  private String email;
}

