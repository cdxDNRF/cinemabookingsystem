package com.xd.cinema.module.showing.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.common.security.UserContext;
import com.xd.cinema.module.showing.dto.ShowingAuditRequest;
import com.xd.cinema.module.showing.entity.Showing;
import com.xd.cinema.module.showing.service.ShowingService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/showings")
@RequireRole(RoleType.ADMIN)
@RequiredArgsConstructor
public class AdminShowingAuditController {

  private final ShowingService showingService;

  @GetMapping
  public ApiResult<List<Showing>> list(@RequestParam(required = false) Integer auditStatus, @RequestParam(required = false) Long cinemaId, @RequestParam(required = false) Long movieId) {
    return ApiResult.ok(showingService.listAdminShowings(auditStatus, cinemaId, movieId));
  }

  @PostMapping("/{id}/audit")
  public ApiResult<Void> audit(@PathVariable Long id, @Valid @RequestBody ShowingAuditRequest req) {
    showingService.auditShowing(UserContext.get().getId(), id, req);
    return ApiResult.ok();
  }
}

