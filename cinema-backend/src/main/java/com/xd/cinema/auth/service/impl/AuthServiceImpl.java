package com.xd.cinema.auth.service.impl;

import com.xd.cinema.auth.dto.LoginRequest;
import com.xd.cinema.auth.dto.LoginResponse;
import com.xd.cinema.auth.dto.RegisterCinemaAdminRequest;
import com.xd.cinema.auth.dto.RegisterUserRequest;
import com.xd.cinema.auth.service.AuthService;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.exception.BizException;
import com.xd.cinema.common.security.JwtUtil;
import com.xd.cinema.common.util.PasswordUtil;
import com.xd.cinema.module.admin.entity.Admin;
import com.xd.cinema.module.admin.mapper.AdminMapper;
import com.xd.cinema.module.cinema.entity.CinemaAdmin;
import com.xd.cinema.module.cinema.mapper.CinemaAdminMapper;
import com.xd.cinema.module.user.entity.User;
import com.xd.cinema.module.user.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

  private final AdminMapper adminMapper;
  private final UserMapper userMapper;
  private final CinemaAdminMapper cinemaAdminMapper;
  private final JwtUtil jwtUtil;

  @Override
  public LoginResponse login(LoginRequest req) {
    RoleType role = req.getRole();
    return switch (role) {
      case ADMIN -> loginAdmin(req);
      case USER -> loginUser(req);
      case CINEMA_ADMIN -> loginCinemaAdmin(req);
    };
  }

  @Override
  public void registerUser(RegisterUserRequest req) {
    if (userMapper.findByUsername(req.getUsername()) != null) {
      throw new BizException(400, "用户名已存在");
    }
    User u = new User();
    u.setUsername(req.getUsername());
    u.setPasswordHash(PasswordUtil.hash(req.getPassword()));
    u.setNickname(req.getNickname());
    u.setPhone(req.getPhone());
    u.setStatus(1);
    userMapper.insert(u);
  }

  @Override
  public void registerCinemaAdmin(RegisterCinemaAdminRequest req) {
    if (cinemaAdminMapper.findByUsername(req.getUsername()) != null) {
      throw new BizException(400, "用户名已存在");
    }
    CinemaAdmin ca = new CinemaAdmin();
    ca.setUsername(req.getUsername());
    ca.setPasswordHash(PasswordUtil.hash(req.getPassword()));
    ca.setRealName(req.getRealName());
    ca.setIdCardNo(req.getIdCardNo());
    ca.setPhone(req.getPhone());
    ca.setEmail(req.getEmail());
    ca.setAuditStatus(0);
    ca.setStatus(1);
    cinemaAdminMapper.insert(ca);
  }

  private LoginResponse loginAdmin(LoginRequest req) {
    Admin admin = adminMapper.findByUsername(req.getUsername());
    if (admin == null || admin.getStatus() == 0) {
      throw new BizException(400, "账号不存在或已禁用");
    }
    if (!PasswordUtil.matches(req.getPassword(), admin.getPasswordHash())) {
      throw new BizException(400, "用户名或密码错误");
    }
    String token = jwtUtil.generateToken(admin.getId(), RoleType.ADMIN, admin.getUsername());
    return new LoginResponse(token, RoleType.ADMIN, admin.getId(), admin.getUsername(), admin.getNickname(), null);
  }

  private LoginResponse loginUser(LoginRequest req) {
    User user = userMapper.findByUsername(req.getUsername());
    if (user == null || user.getStatus() == 0) {
      throw new BizException(400, "账号不存在或已禁用");
    }
    if (!PasswordUtil.matches(req.getPassword(), user.getPasswordHash())) {
      throw new BizException(400, "用户名或密码错误");
    }
    String token = jwtUtil.generateToken(user.getId(), RoleType.USER, user.getUsername());
    return new LoginResponse(token, RoleType.USER, user.getId(), user.getUsername(), user.getNickname(), null);
  }

  private LoginResponse loginCinemaAdmin(LoginRequest req) {
    CinemaAdmin ca = cinemaAdminMapper.findByUsername(req.getUsername());
    if (ca == null || ca.getStatus() == 0) {
      throw new BizException(400, "账号不存在或已禁用");
    }
    if (ca.getAuditStatus() != 1) {
      throw new BizException(400, "账号未审核通过");
    }
    if (!PasswordUtil.matches(req.getPassword(), ca.getPasswordHash())) {
      throw new BizException(400, "用户名或密码错误");
    }
    String token = jwtUtil.generateToken(ca.getId(), RoleType.CINEMA_ADMIN, ca.getUsername());
    return new LoginResponse(token, RoleType.CINEMA_ADMIN, ca.getId(), ca.getUsername(), ca.getRealName(), ca.getCinemaId());
  }
}


