package com.xd.cinema.module.showing.service.impl;

import com.xd.cinema.common.exception.BizException;
import com.xd.cinema.module.cinema.entity.Hall;
import com.xd.cinema.module.cinema.mapper.HallMapper;
import com.xd.cinema.module.movie.mapper.MovieMapper;
import com.xd.cinema.module.showing.dto.ShowingApplyRequest;
import com.xd.cinema.module.showing.dto.ShowingAuditRequest;
import com.xd.cinema.module.showing.entity.Showing;
import com.xd.cinema.module.showing.mapper.ShowingMapper;
import com.xd.cinema.module.showing.service.ShowingService;
import com.xd.cinema.module.showing.vo.ShowingItemVO;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ShowingServiceImpl implements ShowingService {

  private final ShowingMapper showingMapper;
  private final HallMapper hallMapper;
  private final MovieMapper movieMapper;

  @Override
  @Transactional
  public Long applyShowing(Long cinemaAdminId, Long cinemaId, ShowingApplyRequest req) {
    if (movieMapper.findById(req.getMovieId()) == null) {
      throw new BizException(404, "电影不存在");
    }
    Hall hall = hallMapper.findById(req.getHallId());
    if (hall == null || !cinemaId.equals(hall.getCinemaId())) {
      throw new BizException(400, "影厅不存在或不属于本影院");
    }
    if (!req.getEndTime().isAfter(req.getStartTime())) {
      throw new BizException(400, "结束时间必须晚于开始时间");
    }
    Showing s = new Showing();
    s.setCinemaId(cinemaId);
    s.setHallId(req.getHallId());
    s.setMovieId(req.getMovieId());
    s.setStartTime(req.getStartTime());
    s.setEndTime(req.getEndTime());
    s.setTicketPrice(req.getTicketPrice());
    s.setSubmitterCinemaAdminId(cinemaAdminId);
    s.setAuditStatus(0);
    showingMapper.insert(s);
    return s.getId();
  }

  @Override
  public void auditShowing(Long adminId, Long showingId, ShowingAuditRequest req) {
    Showing s = showingMapper.findById(showingId);
    if (s == null) {
      throw new BizException(404, "场次不存在");
    }
    if (Boolean.TRUE.equals(req.getPass())) {
      showingMapper.audit(showingId, 1, adminId, null);
    } else {
      showingMapper.audit(showingId, 2, adminId, req.getReason());
    }
  }

  @Override
  public List<ShowingItemVO> listMyCinemaShowings(Long cinemaId) {
    return showingMapper.listByCinemaAdminVo(cinemaId);
  }

  @Override
  public List<ShowingItemVO> listCinemaShowingsForUser(Long cinemaId, Long movieId) {
    return showingMapper.listByCinemaVo(cinemaId, movieId);
  }

  @Override
  public List<Showing> listAdminShowings(Integer auditStatus, Long cinemaId, Long movieId) {
    return showingMapper.listAdmin(auditStatus, cinemaId, movieId);
  }
}

