package com.xd.cinema.auth.controller;

import com.xd.cinema.auth.dto.LoginRequest;
import com.xd.cinema.auth.dto.LoginResponse;
import com.xd.cinema.auth.dto.RegisterCinemaAdminRequest;
import com.xd.cinema.auth.dto.RegisterUserRequest;
import com.xd.cinema.auth.service.AuthService;
import com.xd.cinema.common.api.ApiResult;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

  private final AuthService authService;

  @PostMapping("/login")
  public ApiResult<LoginResponse> login(@Valid @RequestBody LoginRequest req) {
    return ApiResult.ok(authService.login(req));
  }

  @PostMapping("/register/user")
  public ApiResult<Void> registerUser(@Valid @RequestBody RegisterUserRequest req) {
    authService.registerUser(req);
    return ApiResult.ok();
  }

  @PostMapping("/register/cinema-admin")
  public ApiResult<Void> registerCinemaAdmin(@Valid @RequestBody RegisterCinemaAdminRequest req) {
    authService.registerCinemaAdmin(req);
    return ApiResult.ok();
  }
}


