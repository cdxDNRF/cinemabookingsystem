package com.xd.cinema.common.enums;

public enum AuditStatus {
  PENDING(0),
  APPROVED(1),
  REJECTED(2),
  OFFLINE(3);

  private final int code;

  AuditStatus(int code) {
    this.code = code;
  }

  public int getCode() {
    return code;
  }
}

