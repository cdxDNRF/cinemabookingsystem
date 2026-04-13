package com.xd.cinema.module.notice.mapper;

import com.xd.cinema.module.notice.entity.Notice;
import java.util.List;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface NoticeMapper {

  @Select("select * from t_notice where id=#{id}")
  Notice findById(Long id);

  @Select("select * from t_notice order by id desc")
  List<Notice> listAll();

  @Select("select * from t_notice where publish_status=1 order by publish_time desc, id desc")
  List<Notice> listPublished();

  @Insert("insert into t_notice(title,content,publish_status,publish_time,publisher_admin_id) values(#{title},#{content},#{publishStatus},#{publishTime},#{publisherAdminId})")
  int insert(Notice notice);

  @Update("update t_notice set title=#{title},content=#{content},publish_status=#{publishStatus},publish_time=#{publishTime} where id=#{id}")
  int update(Notice notice);

  @Delete("delete from t_notice where id=#{id}")
  int delete(Long id);
}

