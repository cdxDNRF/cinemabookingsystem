package com.xd.cinema.module.cinema.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CinemaApplyRequest {

  @NotBlank(message = "请输入影院名称")
  private String name;

  @NotBlank(message = "请输入地址")
  private String address;

  private String phone;
  private String email;
  private String tags;
  private String coverUrl;
}

