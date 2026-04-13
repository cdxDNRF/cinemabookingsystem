package com.xd.cinema.module.movie.service.impl;

import com.xd.cinema.common.exception.BizException;
import com.xd.cinema.module.movie.dto.MovieUpsertRequest;
import com.xd.cinema.module.movie.entity.Movie;
import com.xd.cinema.module.movie.entity.MovieStaff;
import com.xd.cinema.module.movie.entity.MovieType;
import com.xd.cinema.module.movie.mapper.MovieMapper;
import com.xd.cinema.module.movie.mapper.MovieStaffMapper;
import com.xd.cinema.module.movie.mapper.MovieTypeMapper;
import com.xd.cinema.module.movie.mapper.MovieTypeRelMapper;
import com.xd.cinema.module.movie.service.MovieService;
import com.xd.cinema.module.movie.vo.MovieDetailVO;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MovieServiceImpl implements MovieService {

  private final MovieTypeMapper movieTypeMapper;
  private final MovieMapper movieMapper;
  private final MovieTypeRelMapper movieTypeRelMapper;
  private final MovieStaffMapper movieStaffMapper;

  @Override
  public List<MovieType> listTypesEnabled() {
    return movieTypeMapper.listEnabled();
  }

  @Override
  public List<MovieType> listTypesAll() {
    return movieTypeMapper.listAll();
  }

  @Override
  public void upsertType(MovieType type) {
    if (type.getId() == null) {
      if (type.getStatus() == null) {
        type.setStatus(1);
      }
      if (type.getSortNo() == null) {
        type.setSortNo(0);
      }
      movieTypeMapper.insert(type);
      return;
    }
    movieTypeMapper.update(type);
  }

  @Override
  public void deleteType(Long id) {
    movieTypeMapper.delete(id);
  }

  @Override
  public List<Movie> listMovies(Integer status, String keyword) {
    return movieMapper.listByStatus(status, keyword);
  }

  @Override
  public List<Movie> listMoviesFilter(Long typeId, Integer year, String region, String keyword) {
    return movieMapper.listFilter(typeId, year, region, keyword);
  }

  @Override
  public MovieDetailVO getDetail(Long movieId) {
    Movie movie = movieMapper.findById(movieId);
    if (movie == null) {
      throw new BizException(404, "电影不存在");
    }
    List<Long> typeIds = movieTypeRelMapper.listTypeIdsByMovieId(movieId);
    List<MovieType> types = new ArrayList<>();
    for (Long tid : typeIds) {
      MovieType t = movieTypeMapper.findById(tid);
      if (t != null) {
        types.add(t);
      }
    }
    List<MovieStaff> staff = movieStaffMapper.listByMovieId(movieId);
    return new MovieDetailVO(movie, types, staff);
  }

  @Override
  @Transactional
  public Long createOrUpdate(MovieUpsertRequest req) {
    if (req.getTypeIds() == null || req.getTypeIds().isEmpty()) {
      throw new BizException(400, "电影至少选择1个类型");
    }
    if (req.getTypeIds().size() > 3) {
      throw new BizException(400, "电影最多选择3个类型");
    }
    Movie movie = new Movie();
    movie.setId(req.getId());
    movie.setName(req.getName());
    movie.setNameEn(req.getNameEn());
    movie.setPosterUrl(req.getPosterUrl());
    movie.setRegion(req.getRegion());
    movie.setYear(req.getYear());
    movie.setLanguage(req.getLanguage());
    movie.setReleaseDate(req.getReleaseDate());
    movie.setDurationMin(req.getDurationMin());
    movie.setIntro(req.getIntro());
    movie.setTrailerJson(req.getTrailerJson());
    movie.setStatus(req.getStatus());
    if (movie.getTotalBoxOffice() == null) {
      movie.setTotalBoxOffice(BigDecimal.ZERO);
    }
    if (movie.getRatingAvg() == null) {
      movie.setRatingAvg(BigDecimal.ZERO);
    }
    if (movie.getRatingCount() == null) {
      movie.setRatingCount(0);
    }

    if (movie.getId() == null) {
      movieMapper.insert(movie);
    } else {
      if (movieMapper.findById(movie.getId()) == null) {
        throw new BizException(404, "电影不存在");
      }
      movieMapper.update(movie);
      movieTypeRelMapper.deleteByMovieId(movie.getId());
    }
    for (Long tid : req.getTypeIds()) {
      movieTypeRelMapper.insert(movie.getId(), tid);
    }
    return movie.getId();
  }

  @Override
  @Transactional
  public void deleteMovie(Long id) {
    movieTypeRelMapper.deleteByMovieId(id);
    movieMapper.delete(id);
  }

  @Override
  public List<Movie> topBoxOffice(int limit) {
    return movieMapper.topBoxOffice(limit);
  }

  @Override
  public List<Movie> topRating(int limit) {
    return movieMapper.topRating(limit);
  }
}

