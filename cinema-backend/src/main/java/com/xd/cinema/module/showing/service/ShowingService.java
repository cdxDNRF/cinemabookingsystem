package com.xd.cinema.module.showing.service;

import com.xd.cinema.module.showing.dto.ShowingApplyRequest;
import com.xd.cinema.module.showing.dto.ShowingAuditRequest;
import com.xd.cinema.module.showing.entity.Showing;
import com.xd.cinema.module.showing.vo.ShowingItemVO;
import java.util.List;

public interface ShowingService {

  Long applyShowing(Long cinemaAdminId, Long cinemaId, ShowingApplyRequest req);

  void auditShowing(Long adminId, Long showingId, ShowingAuditRequest req);

  List<ShowingItemVO> listMyCinemaShowings(Long cinemaId);

  List<ShowingItemVO> listCinemaShowingsForUser(Long cinemaId, Long movieId);

  List<Showing> listAdminShowings(Integer auditStatus, Long cinemaId, Long movieId);
}

