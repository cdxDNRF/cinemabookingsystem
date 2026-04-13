package com.xd.cinema.auth.service;

import com.xd.cinema.auth.dto.LoginRequest;
import com.xd.cinema.auth.dto.LoginResponse;
import com.xd.cinema.auth.dto.RegisterCinemaAdminRequest;
import com.xd.cinema.auth.dto.RegisterUserRequest;

public interface AuthService {
  LoginResponse login(LoginRequest req);

  void registerUser(RegisterUserRequest req);

  void registerCinemaAdmin(RegisterCinemaAdminRequest req);
}


