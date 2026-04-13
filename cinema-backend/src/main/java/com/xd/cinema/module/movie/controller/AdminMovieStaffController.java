package com.xd.cinema.module.movie.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.module.movie.entity.MovieStaff;
import com.xd.cinema.module.movie.mapper.MovieMapper;
import com.xd.cinema.module.movie.mapper.MovieStaffMapper;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/movies")
@RequireRole(RoleType.ADMIN)
@RequiredArgsConstructor
public class AdminMovieStaffController {

  private final MovieMapper movieMapper;
  private final MovieStaffMapper movieStaffMapper;

  @GetMapping("/{movieId}/staff")
  public ApiResult<List<MovieStaff>> list(@PathVariable Long movieId) {
    if (movieMapper.findById(movieId) == null) {
      return ApiResult.fail(404, "电影不存在");
    }
    return ApiResult.ok(movieStaffMapper.listByMovieId(movieId));
  }

  @PostMapping("/{movieId}/staff")
  public ApiResult<Void> upsert(@PathVariable Long movieId, @RequestBody MovieStaff staff) {
    if (movieMapper.findById(movieId) == null) {
      return ApiResult.fail(404, "电影不存在");
    }
    staff.setMovieId(movieId);
    if (staff.getId() == null) {
      if (staff.getSortNo() == null) {
        staff.setSortNo(0);
      }
      movieStaffMapper.insert(staff);
    } else {
      movieStaffMapper.update(staff);
    }
    return ApiResult.ok();
  }

  @DeleteMapping("/staff/{id}")
  public ApiResult<Void> delete(@PathVariable Long id) {
    movieStaffMapper.delete(id);
    return ApiResult.ok();
  }
}

