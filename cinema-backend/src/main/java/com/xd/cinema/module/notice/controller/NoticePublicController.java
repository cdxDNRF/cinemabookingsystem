package com.xd.cinema.module.notice.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.module.notice.entity.Notice;
import com.xd.cinema.module.notice.mapper.NoticeMapper;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/notices")
@RequiredArgsConstructor
public class NoticePublicController {

  private final NoticeMapper noticeMapper;

  @GetMapping
  public ApiResult<List<Notice>> listPublished() {
    return ApiResult.ok(noticeMapper.listPublished());
  }
}

