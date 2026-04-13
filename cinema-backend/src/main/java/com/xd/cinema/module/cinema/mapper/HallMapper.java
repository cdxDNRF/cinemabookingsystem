package com.xd.cinema.module.cinema.mapper;

import com.xd.cinema.module.cinema.entity.Hall;
import java.util.List;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface HallMapper {

  @Select("select * from t_hall where id=#{id}")
  Hall findById(Long id);

  @Select("select * from t_hall where cinema_id=#{cinemaId} order by id desc")
  List<Hall> listByCinemaId(Long cinemaId);

  @Select("select * from t_hall order by id desc")
  List<Hall> listAll();

  @Insert("insert into t_hall(cinema_id,name,seat_rows,seat_cols,status) values(#{cinemaId},#{name},#{seatRows},#{seatCols},#{status})")
  int insert(Hall hall);

  @Update("update t_hall set name=#{name},seat_rows=#{seatRows},seat_cols=#{seatCols},status=#{status} where id=#{id}")
  int update(Hall hall);

  @Delete("delete from t_hall where id=#{id}")
  int delete(Long id);

  @Update("update t_hall set status=#{status} where id=#{id}")
  int updateStatus(@Param("id") Long id, @Param("status") int status);
}

