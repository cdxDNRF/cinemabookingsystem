package com.xd.cinema.module.profile.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ChangePasswordRequest {

  @NotBlank(message = "请输入原密码")
  private String oldPassword;

  @NotBlank(message = "请输入新密码")
  private String newPassword;
}

