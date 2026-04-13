package com.xd.cinema.module.admin.mapper;

import com.xd.cinema.module.admin.entity.Admin;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import org.apache.ibatis.annotations.Insert;
import java.util.List;

@Mapper
public interface AdminMapper {

  @Select("select * from t_admin where username=#{username} limit 1")
  Admin findByUsername(String username);

  @Select("select * from t_admin where id=#{id}")
  Admin findById(Long id);

  @Update("update t_admin set password_hash=#{passwordHash} where id=#{id}")
  int updatePassword(@Param("id") Long id, @Param("passwordHash") String passwordHash);

  @Update("update t_admin set nickname=#{nickname},avatar_url=#{avatarUrl} where id=#{id}")
  int updateProfile(Admin admin);

  @Select("select * from t_admin order by id desc")
  List<Admin> listAll();

  @Insert("insert into t_admin(username,password_hash,nickname,avatar_url,status) values(#{username},#{passwordHash},#{nickname},#{avatarUrl},#{status})")
  int insert(Admin admin);

  @Update("update t_admin set status=#{status} where id=#{id}")
  int updateStatus(@Param("id") Long id, @Param("status") int status);
}

