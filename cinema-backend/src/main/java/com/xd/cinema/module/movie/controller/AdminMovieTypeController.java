package com.xd.cinema.module.movie.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.module.movie.entity.MovieType;
import com.xd.cinema.module.movie.service.MovieService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/movie-types")
@RequireRole(RoleType.ADMIN)
@RequiredArgsConstructor
public class AdminMovieTypeController {

  private final MovieService movieService;

  @GetMapping
  public ApiResult<List<MovieType>> listAll() {
    return ApiResult.ok(movieService.listTypesAll());
  }

  @PostMapping
  public ApiResult<Void> upsert(@RequestBody MovieType type) {
    movieService.upsertType(type);
    return ApiResult.ok();
  }

  @DeleteMapping("/{id}")
  public ApiResult<Void> delete(@PathVariable Long id) {
    movieService.deleteType(id);
    return ApiResult.ok();
  }
}

