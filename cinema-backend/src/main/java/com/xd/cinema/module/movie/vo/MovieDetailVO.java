package com.xd.cinema.module.movie.vo;

import com.xd.cinema.module.movie.entity.Movie;
import com.xd.cinema.module.movie.entity.MovieStaff;
import com.xd.cinema.module.movie.entity.MovieType;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class MovieDetailVO {
  private Movie movie;
  private List<MovieType> types;
  private List<MovieStaff> staff;
}

