package com.xd.cinema.module.movie.service;

import com.xd.cinema.module.movie.dto.MovieUpsertRequest;
import com.xd.cinema.module.movie.entity.Movie;
import com.xd.cinema.module.movie.entity.MovieType;
import com.xd.cinema.module.movie.vo.MovieDetailVO;
import java.util.List;

public interface MovieService {

  List<MovieType> listTypesEnabled();

  List<MovieType> listTypesAll();

  void upsertType(MovieType type);

  void deleteType(Long id);

  List<Movie> listMovies(Integer status, String keyword);

  List<Movie> listMoviesFilter(Long typeId, Integer year, String region, String keyword);

  MovieDetailVO getDetail(Long movieId);

  Long createOrUpdate(MovieUpsertRequest req);

  void deleteMovie(Long id);

  List<Movie> topBoxOffice(int limit);

  List<Movie> topRating(int limit);
}

