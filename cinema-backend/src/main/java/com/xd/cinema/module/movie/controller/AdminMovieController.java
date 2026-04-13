package com.xd.cinema.module.movie.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.module.movie.dto.MovieUpsertRequest;
import com.xd.cinema.module.movie.entity.Movie;
import com.xd.cinema.module.movie.service.MovieService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/movies")
@RequireRole(RoleType.ADMIN)
@RequiredArgsConstructor
public class AdminMovieController {

  private final MovieService movieService;

  @GetMapping
  public ApiResult<List<Movie>> list(@RequestParam(required = false) Integer status, @RequestParam(required = false) String keyword) {
    return ApiResult.ok(movieService.listMovies(status, keyword));
  }

  @PostMapping
  public ApiResult<Long> upsert(@RequestBody MovieUpsertRequest req) {
    return ApiResult.ok(movieService.createOrUpdate(req));
  }

  @DeleteMapping("/{id}")
  public ApiResult<Void> delete(@PathVariable Long id) {
    movieService.deleteMovie(id);
    return ApiResult.ok();
  }
}

