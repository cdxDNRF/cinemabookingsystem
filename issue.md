# 开发问题记录

本文档记录影院管理系统开发过程中遇到的技术难点、问题现象、根因分析与解决方案，便于后续维护与复盘。

---

## 目录

1. [评论功能相关](#1-评论功能相关)
   - [1.1 中文乱码问题](#11-中文乱码问题)
   - [1.2 用户名显示为数字 ID](#12-用户名显示为数字-id)
   - [1.3 评论被覆盖（唯一约束冲突）](#13-评论被覆盖唯一约束冲突)
   - [1.4 无法删除唯一索引（ERROR 1553）](#14-无法删除唯一索引error-1553)
   - [1.5 前端评论 API 需要登录才能查看](#15-前端评论-api-需要登录才能查看)
2. [数据库相关](#2-数据库相关)
3. [前端相关](#3-前端相关)

---

## 1. 评论功能相关

### 1.1 中文乱码问题

**现象**：通过 SQL 文件插入评论数据后，页面显示为问号 `????`。

**根因**：PowerShell 管道传递 SQL 文件时编码被改变，导致中文字符写入数据库时损坏。

**解决**：改用 `mysql` 客户端直接执行 SQL 文件，并显式指定字符集：

```powershell
mysql --default-character-set=utf8mb4 -u root -p cinema -e "source fix_comments.sql"
```

同时确保 SQL 文件本身为 UTF-8 编码，数据库、表、连接均使用 `utf8mb4`。

---

### 1.2 用户名显示为数字 ID

**现象**：评论列表中用户名显示为 `1`、`2` 等数字，而非用户昵称或用户名。

**根因**：
1. 后端 SQL 查询直接返回 `u.username`，但豆瓣模拟用户的昵称存在 `nickname` 字段；
2. 实体类 `MovieUserAction` 缺少 `userName` 字段，无法映射关联查询结果；
3. 前端回退逻辑为 `a.userName || a.userId`，当 `userName` 为空时直接显示数字 ID。

**解决**：

1. **SQL 优化**：优先返回 `nickname`，为空则返回 `username`：
   ```java
   @Select("select a.*, COALESCE(NULLIF(u.nickname, ''), u.username) as userName from t_movie_user_action a left join t_user u on a.user_id = u.id where a.movie_id=#{movieId} and a.score is not null order by a.score_time desc")
   List<MovieUserAction> listComments(Long movieId);
   ```

2. **实体类补充字段**：
   ```java
   @Data
   public class MovieUserAction {
       // ... 其他字段
       // 关联用户名称（非数据库字段）
       private String userName;
   }
   ```

3. **前端回退逻辑优化**：
   ```typescript
   userName: a.userName || a.userId || '匿名用户'
   ```

---

### 1.3 评论被覆盖（唯一约束冲突）

**现象**：用户发表新评论后，旧评论消失，始终只有一条评论。

**根因**：
1. 数据库表 `t_movie_user_action` 存在唯一约束 `uk_user_movie (user_id, movie_id)`，限制同一用户对同一电影只能有一条记录；
2. 后端 `score` 接口先查询是否已有记录，有则执行 `update`，导致新评论覆盖旧评论。

**解决**：

1. **删除唯一约束**：允许同一用户对同一电影发表多条评论。
2. **后端改为插入**：移除更新逻辑，每次评论直接 `insert`：
   ```java
   @PostMapping("/{movieId}/score")
   public ApiResult<Void> score(@PathVariable Long movieId, @RequestBody ScoreBody body) {
       // ... 参数校验
       Long userId = UserContext.get().getId();
       // 每次评论都新增记录，不覆盖旧评论
       MovieUserAction action = new MovieUserAction();
       action.setUserId(userId);
       action.setMovieId(movieId);
       action.setIsFavorite(0);
       action.setScore(body.score);
       action.setScoreTime(LocalDateTime.now());
       action.setContent(body.content);
       actionMapper.insert(action);
       // ... 评分缓存更新逻辑
       return ApiResult.ok();
   }
   ```

---

### 1.4 无法删除唯一索引（ERROR 1553）

**现象**：执行 `ALTER TABLE t_movie_user_action DROP INDEX uk_user_movie;` 报错：
```
ERROR 1553 (HY000): Cannot drop index 'uk_user_movie': needed in a foreign key constraint
```

**根因**：MySQL 认为该唯一索引被外键约束依赖，不允许直接删除。

**解决**：先添加一个普通索引替代，再删除唯一索引：

```sql
-- 1. 添加普通索引
ALTER TABLE t_movie_user_action ADD KEY idx_user_movie (user_id, movie_id);

-- 2. 删除唯一索引
ALTER TABLE t_movie_user_action DROP KEY uk_user_movie;
```

---

### 1.5 前端评论 API 需要登录才能查看

**现象**：未登录用户访问电影详情页时，评论列表无法加载，控制台报错 401。

**根因**：原评论接口 `/api/user/movies/{movieId}/comments` 位于需要用户权限的 Controller 中，带有 `@RequireRole(RoleType.USER)` 注解。

**解决**：在公开接口控制器 `MoviePublicController` 中新增无需登录的评论查询 API：

```java
@GetMapping("/{id}/comments")
public ApiResult<List<MovieUserAction>> comments(@PathVariable Long id) {
    return ApiResult.ok(actionMapper.listComments(id));
}
```

前端同步修改请求路径：
```typescript
const actions = await httpGet<any[]>(`/api/movies/${movieId}/comments`)
```

---

## 2. 数据库相关

| 问题 | 现象 | 解决 |
|------|------|------|
| 中文乱码 | 插入的中文显示为问号 | 统一使用 `utf8mb4` 字符集，通过 `mysql` 客户端直接执行 SQL |
| 唯一索引删除失败 | ERROR 1553 | 先添加普通索引，再删除唯一索引 |
| 外键约束冲突 | 删除或修改表结构时报错 | 先禁用外键检查 `SET FOREIGN_KEY_CHECKS=0`，操作完成后再启用 |

---

## 3. 前端相关

| 问题 | 现象 | 解决 |
|------|------|------|
| 评论 API 401 | 未登录无法查看评论 | 将评论接口从受保护的 `/api/user/...` 迁移到公开的 `/api/movies/...` |
| 用户名显示异常 | 显示数字 ID 或 undefined | 后端返回 `userName`，前端使用 `a.userName \|\| '匿名用户'` 回退 |

---

## 4. 电影海报相关

### 4.1 AI 生成海报替换为真实海报

**现象**：系统中电影海报为 AI 生成图片，质量不佳且缺乏真实感。

**根因**：初期使用占位图片或 AI 生成图片作为海报，未接入真实电影数据源。

**解决**：
1. **接入 TMDB API**：通过 TMDB (The Movie Database) API 获取真实电影海报 URL；
2. **批量更新 SQL**：编写脚本将 30 部电影的海报 URL 更新为 TMDB 真实海报地址：
   ```sql
   UPDATE t_movie SET poster_url = 'https://image.tmdb.org/t/p/w500/xxxxx.jpg' WHERE id = 1;
   ```
3. **前端添加 fallback 机制**：海报加载失败时显示默认占位图：
   ```vue
   <img :src="posterUrl" @error="$event.target.src = '/default-poster.jpg'" />
   ```

### 4.2 豆瓣海报 URL 失效

**现象**：部分电影使用豆瓣海报 URL，但在某些网络环境下无法加载或返回 403。

**根因**：豆瓣图片服务器对 referer 和请求来源有限制，直接引用外链容易被拦截。

**解决**：
1. 统一改用 **TMDB 海报 URL**（`https://image.tmdb.org/t/p/w500/`），该服务对图片外链限制较少；
2. 在数据库中批量替换失效的豆瓣 URL；
3. 前端组件增加错误处理，加载失败时自动切换至默认海报。

### 4.3 海报加载缓慢/空白

**现象**：电影列表页海报加载慢，甚至出现长时间空白。

**根因**：
1. TMDB 服务器位于海外，国内访问速度不稳定；
2. 未对海报图片进行尺寸控制，原图过大；
3. 没有加载状态提示。

**解决**：
1. **使用 TMDB 缩略图尺寸**：将 `w500` 替换为 `w342` 或 `w185` 减少加载体积；
2. **前端添加加载占位**：使用骨架屏或默认灰色占位图，提升感知性能；
3. **组件封装**：创建 `MoviePoster` 组件统一处理加载状态和错误回退：
   ```vue
   <template>
     <div class="poster-wrapper">
       <img v-if="loaded" :src="url" @load="loaded = true" @error="onError" />
       <div v-else class="poster-placeholder">加载中...</div>
     </div>
   </template>
   ```

---

## 总结

评论功能的开发涉及前后端、数据库多个层面的协调。核心教训：

1. **数据库设计阶段**应充分考虑业务扩展性，如评论是否允许多条；
2. **字符集**必须全程统一（数据库、连接、表、文件），避免中文乱码；
3. **前后端数据契约**要清晰，字段命名和回退逻辑需对齐；
4. **公开数据接口**（如评论列表）应与需要认证的接口分离，避免不必要的登录限制。
