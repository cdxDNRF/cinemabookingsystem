package com.xd.cinema.common.enums;

public enum NoticeStatus {
  DRAFT(0),
  PUBLISHED(1),
  OFFLINE(2);

  private final int code;

  NoticeStatus(int code) {
    this.code = code;
  }

  public int getCode() {
    return code;
  }
}

