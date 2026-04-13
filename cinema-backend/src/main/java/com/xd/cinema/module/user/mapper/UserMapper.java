package com.xd.cinema.module.user.mapper;

import com.xd.cinema.module.user.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import java.util.List;

@Mapper
public interface UserMapper {
  @Select("select * from t_user where username=#{username} limit 1")
  User findByUsername(String username);

  @Select("select * from t_user where id=#{id}")
  User findById(Long id);

  @Insert("insert into t_user(username,password_hash,nickname,phone,avatar_url,status) values(#{username},#{passwordHash},#{nickname},#{phone},#{avatarUrl},#{status})")
  int insert(User user);

  @Update("update t_user set nickname=#{nickname},phone=#{phone},avatar_url=#{avatarUrl} where id=#{id}")
  int updateProfile(User user);

  @Update("update t_user set password_hash=#{passwordHash} where id=#{id}")
  int updatePassword(@Param("id") Long id, @Param("passwordHash") String passwordHash);

  @Select("select * from t_user order by id desc")
  List<User> listAll();

  @Update("update t_user set status=#{status} where id=#{id}")
  int updateStatus(@Param("id") Long id, @Param("status") int status);
}

