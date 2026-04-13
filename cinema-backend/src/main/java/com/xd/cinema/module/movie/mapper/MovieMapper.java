package com.xd.cinema.module.movie.mapper;

import com.xd.cinema.module.movie.entity.Movie;
import java.math.BigDecimal;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface MovieMapper {
  Movie findById(Long id);

  List<Movie> listByStatus(@Param("status") Integer status, @Param("keyword") String keyword);

  List<Movie> listFilter(@Param("typeId") Long typeId, @Param("year") Integer year, @Param("region") String region, @Param("keyword") String keyword);

  int insert(Movie movie);

  int update(Movie movie);

  int delete(Long id);

  List<Movie> topBoxOffice(@Param("limit") int limit);

  List<Movie> topRating(@Param("limit") int limit);

  int incBoxOffice(@Param("movieId") Long movieId, @Param("delta") BigDecimal delta);

  int updateRatingCache(@Param("movieId") Long movieId, @Param("avg") BigDecimal avg, @Param("cnt") Integer cnt);
}

