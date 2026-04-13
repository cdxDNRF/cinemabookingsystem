package com.xd.cinema.module.notice.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.common.security.UserContext;
import com.xd.cinema.module.notice.entity.Notice;
import com.xd.cinema.module.notice.mapper.NoticeMapper;
import java.time.LocalDateTime;
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
@RequestMapping("/api/admin/notices")
@RequireRole(RoleType.ADMIN)
@RequiredArgsConstructor
public class AdminNoticeController {

  private final NoticeMapper noticeMapper;

  @GetMapping
  public ApiResult<List<Notice>> listAll() {
    return ApiResult.ok(noticeMapper.listAll());
  }

  @PostMapping
  public ApiResult<Void> upsert(@RequestBody Notice notice) {
    if (notice.getId() == null) {
      if (notice.getPublishStatus() != null && notice.getPublishStatus() == 1 && notice.getPublishTime() == null) {
        notice.setPublishTime(LocalDateTime.now());
      }
      notice.setPublisherAdminId(UserContext.get().getId());
      noticeMapper.insert(notice);
    } else {
      if (notice.getPublishStatus() != null && notice.getPublishStatus() == 1 && notice.getPublishTime() == null) {
        notice.setPublishTime(LocalDateTime.now());
      }
      noticeMapper.update(notice);
    }
    return ApiResult.ok();
  }

  @DeleteMapping("/{id}")
  public ApiResult<Void> delete(@PathVariable Long id) {
    noticeMapper.delete(id);
    return ApiResult.ok();
  }
}

