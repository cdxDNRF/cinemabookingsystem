package com.xd.cinema.common.enums;

public enum OrderStatus {
  PENDING_PAY(0),
  PENDING_TICKET(1),
  FINISHED(2),
  CANCELED(3),
  TIMEOUT_CANCELED(4);

  private final int code;

  OrderStatus(int code) {
    this.code = code;
  }

  public int getCode() {
    return code;
  }
}

