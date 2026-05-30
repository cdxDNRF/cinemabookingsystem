package com.xd.cinema.module.action.controller;

import com.xd.cinema.common.api.ApiResult;
import com.xd.cinema.common.enums.RoleType;
import com.xd.cinema.common.exception.BizException;
import com.xd.cinema.common.security.RequireRole;
import com.xd.cinema.common.security.UserContext;
import com.xd.cinema.module.action.entity.MovieUserAction;
import com.xd.cinema.module.action.mapper.MovieUserActionMapper;
import com.xd.cinema.module.movie.mapper.MovieMapper;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
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
@RequestMapping("/api/user/movies")
@RequireRole(RoleType.USER)
@RequiredArgsConstructor
public class UserMovieActionController {

  private final MovieUserActionMapper actionMapper;
  private final MovieMapper movieMapper;

  @PostMapping("/{movieId}/favorite")
  public ApiResult<Void> favorite(@PathVariable Long movieId, @RequestParam int value) {
    Long userId = UserContext.get().getId();
    MovieUserAction action = actionMapper.find(userId, movieId);
    if (action == null) {
      action = new MovieUserAction();
      action.setUserId(userId);
      action.setMovieId(movieId);
      action.setIsFavorite(value == 1 ? 1 : 0);
      action.setFavoriteTime(value == 1 ? LocalDateTime.now() : null);
      actionMapper.insert(action);
    } else {
      action.setIsFavorite(value == 1 ? 1 : 0);
      action.setFavoriteTime(value == 1 ? LocalDateTime.now() : null);
      actionMapper.update(action);
    }
    return ApiResult.ok();
  }

  @PostMapping("/{movieId}/score")
  public ApiResult<Void> score(@PathVariable Long movieId, @RequestBody ScoreBody body) {
    if (body == null || body.score == null || body.score < 1 || body.score > 10) {
      throw new BizException(400, "评分范围1-10");
    }
    Long userId = UserContext.get().getId();
    MovieUserAction action = actionMapper.find(userId, movieId);
    if (action == null) {
      action = new MovieUserAction();
      action.setUserId(userId);
      action.setMovieId(movieId);
      action.setIsFavorite(0);
      action.setScore(body.score);
      action.setScoreTime(LocalDateTime.now());
      action.setContent(body.content);
      actionMapper.insert(action);
    } else {
      action.setScore(body.score);
      action.setScoreTime(LocalDateTime.now());
      action.setContent(body.content);
      actionMapper.update(action);
    }
    MovieUserActionMapper.RatingRow row = actionMapper.calcRating(movieId);
    BigDecimal avg = row == null || row.avgScore == null ? BigDecimal.ZERO : row.avgScore;
    int cnt = row == null || row.cnt == null ? 0 : row.cnt;
    BigDecimal oneDecimal = avg.setScale(1, RoundingMode.HALF_UP);
    movieMapper.updateRatingCache(movieId, oneDecimal, cnt);
    return ApiResult.ok();
  }

  @GetMapping("/{movieId}/comments")
  public ApiResult<List<MovieUserAction>> comments(@PathVariable Long movieId) {
    return ApiResult.ok(actionMapper.listComments(movieId));
  }

  @GetMapping("/favorites")
  public ApiResult<List<MovieUserAction>> favorites() {
    return ApiResult.ok(actionMapper.listFavorites(UserContext.get().getId()));
  }

  public static class ScoreBody {
    public Integer score;
    public String content;
  }
}
