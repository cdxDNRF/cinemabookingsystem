package com.xd.cinema.common.exception;

import com.xd.cinema.common.api.ApiResult;
import jakarta.validation.ConstraintViolationException;
import lombok.extern.slf4j.Slf4j;
import java.sql.SQLSyntaxErrorException;
import java.sql.SQLException;
import org.mybatis.spring.MyBatisSystemException;
import org.springframework.jdbc.BadSqlGrammarException;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

  @ExceptionHandler(BizException.class)
  public ApiResult<Void> handleBiz(BizException ex) {
    return ApiResult.fail(ex.getCode(), ex.getMessage());
  }

  @ExceptionHandler(MethodArgumentNotValidException.class)
  public ApiResult<Void> handleValid(MethodArgumentNotValidException ex) {
    String msg = ex.getBindingResult().getAllErrors().isEmpty() ? "参数错误"
        : ex.getBindingResult().getAllErrors().get(0).getDefaultMessage();
    return ApiResult.fail(400, msg);
  }

  @ExceptionHandler(ConstraintViolationException.class)
  public ApiResult<Void> handleConstraint(ConstraintViolationException ex) {
    return ApiResult.fail(400, ex.getMessage());
  }

  @ExceptionHandler(HttpMessageNotReadableException.class)
  public ApiResult<Void> handleBadBody(HttpMessageNotReadableException ex) {
    return ApiResult.fail(400, "请求体格式错误");
  }

  @ExceptionHandler(BadSqlGrammarException.class)
  public ApiResult<Void> handleBadSql(BadSqlGrammarException ex) {
    log.error("Bad SQL grammar", ex);
    String msg = ex.getMessage() == null ? "" : ex.getMessage();
    if (msg.contains("doesn't exist") || msg.contains("does not exist")) {
      return ApiResult.fail(500, "数据库未初始化，请先导入 database.sql");
    }
    return ApiResult.fail(500, "数据库异常");
  }

  @ExceptionHandler(MyBatisSystemException.class)
  public ApiResult<Void> handleMyBatis(MyBatisSystemException ex) {
    log.error("MyBatis exception", ex);
    Throwable root = ex;
    while (root.getCause() != null && root.getCause() != root) {
      root = root.getCause();
    }
    String msg = root.getMessage() == null ? "" : root.getMessage();
    if (msg.contains("doesn't exist") || msg.contains("does not exist")) {
      return ApiResult.fail(500, "数据库未初始化，请先导入 database.sql");
    }
    if (msg.contains("Access denied")) {
      return ApiResult.fail(500, "数据库账号或密码错误");
    }
    return ApiResult.fail(500, "数据库异常");
  }

  @ExceptionHandler(SQLSyntaxErrorException.class)
  public ApiResult<Void> handleSqlSyntax(SQLSyntaxErrorException ex) {
    log.error("SQL syntax error", ex);
    return ApiResult.fail(500, "数据库未初始化，请先导入 database.sql");
  }

  @ExceptionHandler(SQLException.class)
  public ApiResult<Void> handleSql(SQLException ex) {
    log.error("SQL error", ex);
    String msg = ex.getMessage() == null ? "数据库异常" : ex.getMessage();
    if (msg.contains("Access denied")) {
      return ApiResult.fail(500, "数据库账号或密码错误");
    }
    if (msg.contains("Unknown database")) {
      return ApiResult.fail(500, "数据库不存在，请先导入 database.sql");
    }
    return ApiResult.fail(500, "数据库异常");
  }

  @ExceptionHandler(Exception.class)
  public ApiResult<Void> handleAny(Exception ex) {
    log.error("Unhandled exception", ex);
    return ApiResult.fail(500, "服务器异常");
  }
}
