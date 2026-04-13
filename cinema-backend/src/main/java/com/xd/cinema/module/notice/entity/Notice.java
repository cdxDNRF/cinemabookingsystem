package com.xd.cinema.module.notice.entity;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class Notice {
  private Long id;
  private String title;
  private String content;
  private Integer publishStatus;
  private LocalDateTime publishTime;
  private Long publisherAdminId;
  private LocalDateTime createdTime;
  private LocalDateTime updatedTime;
}

