package com.xd.cinema.module.user.entity;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class User {
  private Long id;
  private String username;
  private String passwordHash;
  private String nickname;
  private String phone;
  private String avatarUrl;
  private Integer status;
  private LocalDateTime lastLoginTime;
  private LocalDateTime createdTime;
  private LocalDateTime updatedTime;
}

