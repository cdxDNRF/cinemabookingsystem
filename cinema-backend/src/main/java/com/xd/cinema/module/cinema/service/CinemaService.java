package com.xd.cinema.module.cinema.service;

import com.xd.cinema.module.cinema.dto.CinemaApplyRequest;
import com.xd.cinema.module.cinema.entity.Cinema;
import com.xd.cinema.module.cinema.entity.Hall;
import java.util.List;

public interface CinemaService {

  List<Cinema> listEnabledCinemas();

  List<Cinema> listAllCinemas();

  void upsertCinema(Cinema cinema);

  void updateCinemaStatus(Long id, int status);

  Long applyCinemaForCurrentCinemaAdmin(CinemaApplyRequest req);

  List<Hall> listMyHalls(Long cinemaId);

  void upsertHall(Hall hall, Long cinemaId);

  void deleteHall(Long id, Long cinemaId);
}

