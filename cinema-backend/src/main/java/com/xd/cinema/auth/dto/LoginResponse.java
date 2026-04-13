package com.xd.cinema.auth.dto;

import com.xd.cinema.common.enums.RoleType;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class LoginResponse {
  private String token;
  private RoleType role;
  private Long userId;
  private String username;
  private String nickname;
  private Long cinemaId;
}

