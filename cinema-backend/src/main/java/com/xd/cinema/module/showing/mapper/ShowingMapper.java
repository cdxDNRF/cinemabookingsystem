package com.xd.cinema.module.showing.mapper;

import com.xd.cinema.module.showing.entity.Showing;
import com.xd.cinema.module.showing.vo.ShowingItemVO;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ShowingMapper {
  Showing findById(Long id);

  List<Showing> listAdmin(@Param("auditStatus") Integer auditStatus, @Param("cinemaId") Long cinemaId, @Param("movieId") Long movieId);

  List<Showing> listByCinema(@Param("cinemaId") Long cinemaId, @Param("movieId") Long movieId);

  List<ShowingItemVO> listByCinemaVo(@Param("cinemaId") Long cinemaId, @Param("movieId") Long movieId);

  List<Showing> listByCinemaAdmin(@Param("cinemaId") Long cinemaId);

  List<ShowingItemVO> listByCinemaAdminVo(@Param("cinemaId") Long cinemaId);

  int insert(Showing showing);

  int audit(@Param("id") Long id, @Param("auditStatus") int auditStatus, @Param("adminId") Long adminId, @Param("reason") String reason);

  int delete(Long id);
}

