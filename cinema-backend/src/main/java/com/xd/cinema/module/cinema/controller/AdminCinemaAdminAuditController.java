package com.xd.cinema.module.cinema.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.exception.BizException;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.common.security.UserContext;
import com.xd.cinema.module.cinema.dto.CinemaAdminAuditRequest;
import com.xd.cinema.module.cinema.entity.CinemaAdmin;
import com.xd.cinema.module.cinema.mapper.CinemaAdminMapper;
import com.xd.cinema.module.cinema.mapper.CinemaMapper;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/cinema-admins")
@RequireRole(RoleType.ADMIN)
@RequiredArgsConstructor
public class AdminCinemaAdminAuditController {

  private final CinemaAdminMapper cinemaAdminMapper;
  private final CinemaMapper cinemaMapper;

  @GetMapping("/pending")
  public ApiResult<List<CinemaAdmin>> listPending() {
    return ApiResult.ok(cinemaAdminMapper.listPending());
  }

  @PostMapping("/{id}/audit")
  public ApiResult<Void> audit(@PathVariable Long id, @Valid @RequestBody CinemaAdminAuditRequest req) {
    CinemaAdmin ca = cinemaAdminMapper.findById(id);
    if (ca == null) {
      throw new BizException(404, "账号不存在");
    }
    if (ca.getCinemaId() == null) {
      throw new BizException(400, "该账号尚未提交影院信息");
    }
    Long adminId = UserContext.get().getId();
    if (Boolean.TRUE.equals(req.getPass())) {
      cinemaAdminMapper.audit(id, 1, adminId, null, ca.getCinemaId());
      cinemaMapper.updateStatus(ca.getCinemaId(), 1);
    } else {
      cinemaAdminMapper.audit(id, 2, adminId, req.getReason(), ca.getCinemaId());
      cinemaMapper.updateStatus(ca.getCinemaId(), 0);
    }
    return ApiResult.ok();
  }
}

