package com.xd.cinema.common.security;

import cn.hutool.core.date.DateUtil;
import cn.hutool.jwt.JWT;
import cn.hutool.jwt.JWTUtil;
import com.xd.cinema.common.enums.RoleType;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class JwtUtil {

  @Value("${cinema.jwt.secret}")
  private String secret;

  @Value("${cinema.jwt.expire-hours:24}")
  private int expireHours;

  public String generateToken(Long userId, RoleType role, String username) {
    Date exp = DateUtil.offsetHour(new Date(), expireHours);
    Map<String, Object> payload = new HashMap<>();
    payload.put("uid", userId);
    payload.put("role", role.name());
    payload.put("username", username);
    payload.put("exp", exp.getTime());

    JWT jwt = JWT.create();
    for (Map.Entry<String, Object> e : payload.entrySet()) {
      jwt.setPayload(e.getKey(), e.getValue());
    }
    return jwt.setKey(secret.getBytes(StandardCharsets.UTF_8)).sign();
  }

  public UserPrincipal parse(String token) {
    JWT jwt = JWTUtil.parseToken(token);
    boolean ok = JWTUtil.verify(token, secret.getBytes(StandardCharsets.UTF_8));
    if (!ok) {
      return null;
    }
    Object expObj = jwt.getPayload("exp");
    long exp = expObj == null ? 0L : Long.parseLong(String.valueOf(expObj));
    if (System.currentTimeMillis() > exp) {
      return null;
    }
    Long uid = Long.parseLong(String.valueOf(jwt.getPayload("uid")));
    RoleType role = RoleType.valueOf(String.valueOf(jwt.getPayload("role")));
    String username = String.valueOf(jwt.getPayload("username"));
    return new UserPrincipal(uid, role, username);
  }
}
