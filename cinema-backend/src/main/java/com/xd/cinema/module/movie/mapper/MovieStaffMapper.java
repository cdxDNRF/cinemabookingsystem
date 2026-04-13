package com.xd.cinema.module.movie.mapper;

import com.xd.cinema.module.movie.entity.MovieStaff;
import java.util.List;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface MovieStaffMapper {

  @Select("select * from t_movie_staff where movie_id=#{movieId} order by role_type asc, sort_no asc, id asc")
  List<MovieStaff> listByMovieId(Long movieId);

  @Insert("insert into t_movie_staff(movie_id,role_type,name,avatar_url,sort_no) values(#{movieId},#{roleType},#{name},#{avatarUrl},#{sortNo})")
  int insert(MovieStaff staff);

  @Update("update t_movie_staff set role_type=#{roleType},name=#{name},avatar_url=#{avatarUrl},sort_no=#{sortNo} where id=#{id}")
  int update(MovieStaff staff);

  @Delete("delete from t_movie_staff where id=#{id}")
  int delete(Long id);
}

