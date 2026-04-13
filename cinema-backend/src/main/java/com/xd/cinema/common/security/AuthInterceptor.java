package com.xd.cinema.common.security;

import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.exception.BizException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import org.springframework.stereotype.Component;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class AuthInterceptor implements HandlerInterceptor {

  private final JwtUtil jwtUtil;

  public AuthInterceptor(JwtUtil jwtUtil) {
    this.jwtUtil = jwtUtil;
  }

  @Override
  public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
    if (!(handler instanceof HandlerMethod hm)) {
      return true;
    }
    RequireRole requireRole = hm.getMethodAnnotation(RequireRole.class);
    if (requireRole == null) {
      requireRole = hm.getBeanType().getAnnotation(RequireRole.class);
    }
    if (requireRole == null) {
      return true;
    }
    String auth = request.getHeader("Authorization");
    if (auth == null || !auth.startsWith("Bearer ")) {
      throw new BizException(401, "未登录");
    }
    String token = auth.substring("Bearer ".length()).trim();
    UserPrincipal principal = jwtUtil.parse(token);
    if (principal == null) {
      throw new BizException(401, "登录已过期");
    }
    Set<RoleType> allow = new HashSet<>(Arrays.asList(requireRole.value()));
    if (!allow.contains(principal.getRole())) {
      throw new BizException(403, "无权限");
    }
    UserContext.set(principal);
    return true;
  }

  @Override
  public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
    UserContext.clear();
  }
}

