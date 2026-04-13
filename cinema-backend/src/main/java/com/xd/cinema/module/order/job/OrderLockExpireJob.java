package com.xd.cinema.module.order.job;

import com.xd.cinema.module.order.mapper.OrderMapper;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@RequiredArgsConstructor
public class OrderLockExpireJob {

  private final OrderMapper orderMapper;

  @Scheduled(fixedDelay = 30000, initialDelay = 30000)
  @Transactional
  public void run() {
    try {
      List<Long> ids = orderMapper.listExpiredLockOrderIds();
      if (ids == null || ids.isEmpty()) {
        return;
      }
      String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
      for (Long id : ids) {
        orderMapper.markTimeoutCanceled(id, now);
      }
    } catch (Exception ignored) {
      return;
    }
  }
}
