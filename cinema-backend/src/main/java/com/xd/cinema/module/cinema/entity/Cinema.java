package com.xd.cinema.module.cinema.entity;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class Cinema {
  private Long id;
  private String name;
  private String coverUrl;
  private String tags;
  private String address;
  private String phone;
  private String email;
  private Integer status;
  private LocalDateTime createdTime;
  private LocalDateTime updatedTime;
}

