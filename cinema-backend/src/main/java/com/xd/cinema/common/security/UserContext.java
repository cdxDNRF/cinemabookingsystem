package com.xd.cinema.common.security;

public class UserContext {
  private static final ThreadLocal<UserPrincipal> HOLDER = new ThreadLocal<>();

  public static void set(UserPrincipal principal) {
    HOLDER.set(principal);
  }

  public static UserPrincipal get() {
    return HOLDER.get();
  }

  public static void clear() {
    HOLDER.remove();
  }
}

