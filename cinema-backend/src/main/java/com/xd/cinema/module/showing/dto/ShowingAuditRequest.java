package com.xd.cinema.module.showing.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ShowingAuditRequest {

  @NotNull(message = "缺少审核结果")
  private Boolean pass;

  private String reason;
}

