package com.xd.cinema.module.cinema.entity;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class CinemaAdmin {
  private Long id;
  private String username;
  private String passwordHash;
  private String realName;
  private String idCardNo;
  private String phone;
  private String email;
  private Long cinemaId;
  private Integer auditStatus;
  private String auditReason;
  private Long auditedByAdminId;
  private LocalDateTime auditedTime;
  private Integer status;
  private LocalDateTime lastLoginTime;
  private LocalDateTime createdTime;
  private LocalDateTime updatedTime;
}

