package com.xd.cinema.module.cinema.mapper;

import com.xd.cinema.module.cinema.entity.CinemaAdmin;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface CinemaAdminMapper {
  @Select("select * from t_cinema_admin where username=#{username} limit 1")
  CinemaAdmin findByUsername(String username);

  @Select("select * from t_cinema_admin where id=#{id}")
  CinemaAdmin findById(Long id);

  @Insert("insert into t_cinema_admin(username,password_hash,real_name,id_card_no,phone,email,cinema_id,audit_status,status) values(#{username},#{passwordHash},#{realName},#{idCardNo},#{phone},#{email},#{cinemaId},#{auditStatus},#{status})")
  int insert(CinemaAdmin ca);

  @Update("update t_cinema_admin set real_name=#{realName},id_card_no=#{idCardNo},phone=#{phone},email=#{email} where id=#{id}")
  int updateProfile(CinemaAdmin ca);

  @Update("update t_cinema_admin set password_hash=#{passwordHash} where id=#{id}")
  int updatePassword(@Param("id") Long id, @Param("passwordHash") String passwordHash);

  @Select("select * from t_cinema_admin where audit_status=0 order by id desc")
  List<CinemaAdmin> listPending();

  @Update("update t_cinema_admin set audit_status=#{auditStatus},audit_reason=#{reason},audited_by_admin_id=#{adminId},audited_time=now(),cinema_id=#{cinemaId} where id=#{id}")
  int audit(@Param("id") Long id, @Param("auditStatus") int auditStatus, @Param("adminId") Long adminId, @Param("reason") String reason, @Param("cinemaId") Long cinemaId);

  @Update("update t_cinema_admin set cinema_id=#{cinemaId} where id=#{id}")
  int updateCinemaId(@Param("id") Long id, @Param("cinemaId") Long cinemaId);

  @Select("select * from t_cinema_admin order by id desc")
  List<CinemaAdmin> listAll();

  @Update("update t_cinema_admin set status=#{status} where id=#{id}")
  int updateStatus(@Param("id") Long id, @Param("status") int status);
}

