package com.xd.cinema.module.action.mapper;

import com.xd.cinema.module.action.entity.MovieUserAction;
import java.math.BigDecimal;
import java.util.List;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface MovieUserActionMapper {

  @Select("select * from t_movie_user_action where user_id=#{userId} and movie_id=#{movieId} limit 1")
  MovieUserAction find(Long userId, Long movieId);

  @Insert("insert into t_movie_user_action(user_id,movie_id,is_favorite,favorite_time,score,score_time) values(#{userId},#{movieId},#{isFavorite},#{favoriteTime},#{score},#{scoreTime})")
  int insert(MovieUserAction action);

  @Update("update t_movie_user_action set is_favorite=#{isFavorite},favorite_time=#{favoriteTime},score=#{score},score_time=#{scoreTime} where id=#{id}")
  int update(MovieUserAction action);

  @Select("select * from t_movie_user_action where user_id=#{userId} and is_favorite=1 order by favorite_time desc")
  List<MovieUserAction> listFavorites(Long userId);

  @Select("select ifnull(avg(score),0) as avgScore, count(score) as cnt from t_movie_user_action where movie_id=#{movieId} and score is not null")
  RatingRow calcRating(Long movieId);

  class RatingRow {
    public BigDecimal avgScore;
    public Integer cnt;
  }
}

