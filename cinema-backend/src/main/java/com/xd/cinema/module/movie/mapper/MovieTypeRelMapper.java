package com.xd.cinema.module.movie.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface MovieTypeRelMapper {

  @Select("select type_id from t_movie_type_rel where movie_id=#{movieId}")
  List<Long> listTypeIdsByMovieId(Long movieId);

  @Select("select count(1) from t_movie_type_rel where movie_id=#{movieId}")
  int countByMovieId(Long movieId);

  @Insert("insert into t_movie_type_rel(movie_id,type_id) values(#{movieId},#{typeId})")
  int insert(@Param("movieId") Long movieId, @Param("typeId") Long typeId);

  @Delete("delete from t_movie_type_rel where movie_id=#{movieId}")
  int deleteByMovieId(Long movieId);
}

