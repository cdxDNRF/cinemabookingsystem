package com.xd.cinema.common.api;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ApiResult<T> {
  private int code;
  private String message;
  private T data;

  public static <T> ApiResult<T> ok(T data) {
    return new ApiResult<>(0, "OK", data);
  }

  public static ApiResult<Void> ok() {
    return new ApiResult<>(0, "OK", null);
  }

  public static <T> ApiResult<T> fail(int code, String message) {
    return new ApiResult<>(code, message, null);
  }
}

