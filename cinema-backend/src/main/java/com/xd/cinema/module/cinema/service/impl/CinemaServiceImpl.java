package com.xd.cinema.module.cinema.service.impl;

import com.xd.cinema.common.exception.BizException;
import com.xd.cinema.common.security.UserContext;
import com.xd.cinema.module.cinema.dto.CinemaApplyRequest;
import com.xd.cinema.module.cinema.entity.Cinema;
import com.xd.cinema.module.cinema.entity.CinemaAdmin;
import com.xd.cinema.module.cinema.entity.Hall;
import com.xd.cinema.module.cinema.mapper.CinemaAdminMapper;
import com.xd.cinema.module.cinema.mapper.CinemaMapper;
import com.xd.cinema.module.cinema.mapper.HallMapper;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CinemaServiceImpl implements com.xd.cinema.module.cinema.service.CinemaService {

  private final CinemaMapper cinemaMapper;
  private final HallMapper hallMapper;
  private final CinemaAdminMapper cinemaAdminMapper;

  @Override
  public List<Cinema> listEnabledCinemas() {
    return cinemaMapper.listEnabled();
  }

  @Override
  public List<Cinema> listAllCinemas() {
    return cinemaMapper.listAll();
  }

  @Override
  public void upsertCinema(Cinema cinema) {
    if (cinema.getId() == null) {
      if (cinema.getStatus() == null) {
        cinema.setStatus(0);
      }
      cinemaMapper.insert(cinema);
      return;
    }
    cinemaMapper.update(cinema);
  }

  @Override
  public void updateCinemaStatus(Long id, int status) {
    cinemaMapper.updateStatus(id, status);
  }

  @Override
  @Transactional
  public Long applyCinemaForCurrentCinemaAdmin(CinemaApplyRequest req) {
    Long cinemaAdminId = UserContext.get().getId();
    CinemaAdmin ca = cinemaAdminMapper.findById(cinemaAdminId);
    if (ca == null) {
      throw new BizException(400, "账号不存在");
    }
    if (ca.getCinemaId() != null) {
      throw new BizException(400, "已绑定影院");
    }
    Cinema cinema = new Cinema();
    cinema.setName(req.getName());
    cinema.setAddress(req.getAddress());
    cinema.setPhone(req.getPhone());
    cinema.setEmail(req.getEmail());
    cinema.setTags(req.getTags());
    cinema.setCoverUrl(req.getCoverUrl());
    cinema.setStatus(0);
    cinemaMapper.insert(cinema);
    cinemaAdminMapper.updateCinemaId(cinemaAdminId, cinema.getId());
    return cinema.getId();
  }

  @Override
  public List<Hall> listMyHalls(Long cinemaId) {
    return hallMapper.listByCinemaId(cinemaId);
  }

  @Override
  public void upsertHall(Hall hall, Long cinemaId) {
    if (hall.getCinemaId() == null) {
      hall.setCinemaId(cinemaId);
    }
    if (!cinemaId.equals(hall.getCinemaId())) {
      throw new BizException(403, "只能操作本影院影厅");
    }
    if (hall.getSeatRows() == null) {
      hall.setSeatRows(8);
    }
    if (hall.getSeatCols() == null) {
      hall.setSeatCols(8);
    }
    if (hall.getStatus() == null) {
      hall.setStatus(1);
    }
    if (hall.getId() == null) {
      hallMapper.insert(hall);
      return;
    }
    Hall db = hallMapper.findById(hall.getId());
    if (db == null || !cinemaId.equals(db.getCinemaId())) {
      throw new BizException(404, "影厅不存在");
    }
    hallMapper.update(hall);
  }

  @Override
  public void deleteHall(Long id, Long cinemaId) {
    Hall db = hallMapper.findById(id);
    if (db == null || !cinemaId.equals(db.getCinemaId())) {
      throw new BizException(404, "影厅不存在");
    }
    hallMapper.delete(id);
  }
}

