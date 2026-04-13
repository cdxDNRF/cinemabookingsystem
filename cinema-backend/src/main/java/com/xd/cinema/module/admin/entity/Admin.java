package com.xd.cinema.module.admin.entity;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class Admin {
  private Long id;
  private String username;
  private String passwordHash;
  private String nickname;
  private String avatarUrl;
  private Integer status;
  private LocalDateTime lastLoginTime;
  private LocalDateTime createdTime;
  private LocalDateTime updatedTime;
}

