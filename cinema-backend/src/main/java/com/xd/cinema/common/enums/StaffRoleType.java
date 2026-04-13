package com.xd.cinema.common.enums;

public enum StaffRoleType {
  DIRECTOR(1),
  WRITER(2),
  ACTOR(3),
  OTHER(4);

  private final int code;

  StaffRoleType(int code) {
    this.code = code;
  }

  public int getCode() {
    return code;
  }
}

