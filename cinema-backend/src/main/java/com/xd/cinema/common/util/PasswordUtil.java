package com.xd.cinema.common.util;

import cn.hutool.crypto.digest.DigestUtil;

public class PasswordUtil {

  public static String hash(String raw) {
    return DigestUtil.sha256Hex(raw);
  }

  public static boolean matches(String raw, String hash) {
    return hash(raw).equalsIgnoreCase(hash);
  }
}

