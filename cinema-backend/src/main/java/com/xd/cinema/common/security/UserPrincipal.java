package com.xd.cinema.common.security;

import com.xd.cinema.common.enums.RoleType;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class UserPrincipal {
  private Long id;
  private RoleType role;
  private String username;
}

