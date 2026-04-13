package com.xd.cinema.module.movie.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.module.movie.entity.Movie;
import com.xd.cinema.module.movie.entity.MovieType;
import com.xd.cinema.module.movie.service.MovieService;
import com.xd.cinema.module.movie.vo.MovieDetailVO;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/movies")
@RequiredArgsConstructor
public class MoviePublicController {

  private final MovieService movieService;

  @GetMapping("/types")
  public ApiResult<List<MovieType>> types() {
    return ApiResult.ok(movieService.listTypesEnabled());
  }

  @GetMapping
  public ApiResult<List<Movie>> list(
      @RequestParam(required = false) Long typeId,
      @RequestParam(required = false) Integer year,
      @RequestParam(required = false) String region,
      @RequestParam(required = false) String keyword
  ) {
    return ApiResult.ok(movieService.listMoviesFilter(typeId, year, region, keyword));
  }

  @GetMapping("/{id}")
  public ApiResult<MovieDetailVO> detail(@PathVariable("id") Long id) {
    return ApiResult.ok(movieService.getDetail(id));
  }

  @GetMapping("/top/box-office")
  public ApiResult<List<Movie>> topBoxOffice(@RequestParam(defaultValue = "10") int limit) {
    return ApiResult.ok(movieService.topBoxOffice(limit));
  }

  @GetMapping("/top/rating")
  public ApiResult<List<Movie>> topRating(@RequestParam(defaultValue = "10") int limit) {
    return ApiResult.ok(movieService.topRating(limit));
  }
}

