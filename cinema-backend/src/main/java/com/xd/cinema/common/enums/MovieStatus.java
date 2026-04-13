package com.xd.cinema.common.enums;

public enum MovieStatus {
  UPCOMING(0),
  ON(1),
  OFF(2);

  private final int code;

  MovieStatus(int code) {
    this.code = code;
  }

  public int getCode() {
    return code;
  }
}

