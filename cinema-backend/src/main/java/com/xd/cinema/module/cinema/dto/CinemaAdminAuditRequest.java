package com.xd.cinema.module.cinema.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CinemaAdminAuditRequest {
  @NotNull(message = "缺少审核结果")
  private Boolean pass;
  private String reason;
}

