package com.xd.cinema.module.showing.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.common.security.UserContext;
import com.xd.cinema.module.showing.dto.ShowingApplyRequest;
import com.xd.cinema.module.showing.entity.Showing;
import com.xd.cinema.module.showing.service.ShowingService;
import com.xd.cinema.module.showing.vo.ShowingItemVO;
import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/showings")
@RequireRole(RoleType.ADMIN)
@RequiredArgsConstructor
public class AdminShowingController {

  private final ShowingService showingService;

  @GetMapping("/all")
  public ApiResult<List<Showing>> listAll(
      @RequestParam(required = false) Long movieId,
      @RequestParam(required = false) Long cinemaId,
      @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
    return ApiResult.ok(showingService.listAdminShowings(null, cinemaId, movieId));
  }

  @PutMapping("/{id}")
  public ApiResult<Void> update(@PathVariable Long id, @Valid @RequestBody ShowingApplyRequest req) {
    showingService.adminUpdateShowing(id, req);
    return ApiResult.ok();
  }

  @DeleteMapping("/{id}")
  public ApiResult<Void> delete(@PathVariable Long id) {
    showingService.adminDeleteShowing(id);
    return ApiResult.ok();
  }
}
