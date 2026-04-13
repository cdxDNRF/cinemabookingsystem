package com.xd.cinema.module.cinema.mapper;

import com.xd.cinema.module.cinema.entity.Cinema;
import java.util.List;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface CinemaMapper {

  @Select("select * from t_cinema where id=#{id}")
  Cinema findById(Long id);

  @Select("select * from t_cinema where status=1 order by id desc")
  List<Cinema> listEnabled();

  @Select("select * from t_cinema order by id desc")
  List<Cinema> listAll();

  @Insert("insert into t_cinema(name,cover_url,tags,address,phone,email,status) values(#{name},#{coverUrl},#{tags},#{address},#{phone},#{email},#{status})")
  int insert(Cinema cinema);

  @Update("update t_cinema set name=#{name},cover_url=#{coverUrl},tags=#{tags},address=#{address},phone=#{phone},email=#{email},status=#{status} where id=#{id}")
  int update(Cinema cinema);

  @Update("update t_cinema set status=#{status} where id=#{id}")
  int updateStatus(@Param("id") Long id, @Param("status") int status);
}

