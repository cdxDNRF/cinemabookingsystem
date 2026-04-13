package com.xd.cinema.module.movie.mapper;

import com.xd.cinema.module.movie.entity.MovieType;
import java.util.List;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface MovieTypeMapper {

  @Select("select * from t_movie_type where id=#{id}")
  MovieType findById(Long id);

  @Select("select * from t_movie_type where status=1 order by sort_no asc, id asc")
  List<MovieType> listEnabled();

  @Select("select * from t_movie_type order by sort_no asc, id asc")
  List<MovieType> listAll();

  @Insert("insert into t_movie_type(name,sort_no,status) values(#{name},#{sortNo},#{status})")
  int insert(MovieType type);

  @Update("update t_movie_type set name=#{name},sort_no=#{sortNo},status=#{status} where id=#{id}")
  int update(MovieType type);

  @Delete("delete from t_movie_type where id=#{id}")
  int delete(Long id);
}

