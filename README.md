# 电影购票网站（仿猫眼电影）

本仓库是一个**前后端完全分离**的电影购票系统，包含三种角色：

- 超级管理员（Admin）
- 影院管理员（Cinema Admin）
- 普通用户（User）

并实现：多影院、多影厅、多场次；在线 8×8 选座（锁座/超时释放）；ECharts 数据统计；预告片视频播放；订单二层展开座位信息等。

## 技术栈（严格遵守）

- 后端：Spring Boot 3 + MyBatis + Hutool + Lombok + MySQL
- 前端：Vue3 + TypeScript + Element-Plus + Vue-Router + Axios + Pinia + Echarts
- 数据库：MySQL 5.7 / 8.0（建议 8.0）
- JDK：>= 17
- Node.js：>= 18
- Maven：>= 3.8

## 项目结构

- `cinema-backend/`：后端工程（REST API）
- `cinema-frontend/`：前端工程（Vite + Vue3）
- `database.sql`：14 张表 + 外键 + 初始化数据

## 数据库（14 张表）

所有表均使用：`t_` 前缀 + `utf8mb4_unicode_ci`。

导入方式：

1. 启动 MySQL
2. 执行根目录的 `database.sql`

```sql
source /path/to/database.sql;
```

## 本地启动

### 0）前置条件

- MySQL 已启动，可连接（默认连接 `127.0.0.1:3306`）
- 已导入 `database.sql`

### 1）启动后端（cinema-backend）

后端默认端口：`8080`。

1. 复制一份本地配置（不要把密码提交到 Git）

将 `cinema-backend/src/main/resources/application-local.example.yml` 复制为：

`cinema-backend/src/main/resources/application-local.yml`

并修改：

- `spring.datasource.username/password`
- `cinema.jwt.secret`

2. 启动

```bash
cd cinema-backend
mvn spring-boot:run
```

启动成功后：

- API 基地址：`http://localhost:8080/api`

### 2）启动前端（cinema-frontend）

前端默认端口：`5173`。

```bash
cd cinema-frontend
npm install
npm run dev
```

访问：`http://127.0.0.1:5173/`

说明：开发环境已在 `vite.config.ts` 配好代理：`/api -> http://localhost:8080`。

## 测试账号

初始化数据在 `database.sql` 中。

- 超级管理员（Admin）
  - 用户名：`admin`
  - 密码：`123456`

- 普通用户（User）
  - 用户名：`zhangsan` / `lisi`
  - 密码：`123456`

- 影院管理员（Cinema Admin）
  - 已审核通过：用户名 `cinema1`，密码 `123456`
  - 待审核：用户名 `cinema2`，密码 `123456`

## 使用说明（核心流程）

### 普通用户

- 首页：热播/待映、Top10、今日票房
- 电影列表：按类型/年代/地区筛选
- 电影详情：简介、演职人员、预告片播放
- 选座购票：8×8 座位图（占用/可选/已选）+ 下单锁座 + 支付/取消
- 我的订单：支持按订单号查询；可取消待支付/待取票订单
- 收藏与评分：评分 1-10，并更新电影评分榜

### 影院管理员

- 注册后提交影院信息，等待管理员审核
- 影厅管理：默认 8×8
- 场次管理：提交放映申请，等待管理员审批
- 订单管理：查看本影院订单

### 超级管理员

- 统计首页：近 7 日票房折线 + 类型数量饼图 + 类型票房柱图（ECharts）
- 影院管理员审核
- 电影类型/电影信息/演职人员管理
- 场次审核（通用审批模型）
- 影厅房间全局管理
- 全部订单管理
- 公告管理
- 用户/管理员/影院管理员账号管理

## 配置与安全

- 不要把真实密码写进公共配置并提交到 Git
  - 后端使用 `application-local.yml`（已在 `.gitignore` 忽略）
  - 前端生产环境通过 `VITE_API_BASE_URL` 配置后端地址

## 前端构建与检查

```bash
cd cinema-frontend
npm run check
npm run lint
npm run build
```

## 后端测试与打包

```bash
cd cinema-backend
mvn test
mvn -DskipTests package
```

## 部署

### 前端（Vercel）

本仓库已提供 `vercel.json`（单页应用 history 路由回退到 `index.html`）。

- 生产环境需要在 Vercel 环境变量里设置：`VITE_API_BASE_URL` 为你的后端公网地址
- 重新部署后即可联调

### 后端

后端是 Spring Boot 服务，需要部署到可公网访问的服务器（或使用内网穿透）。

## 开发流程建议

1. 数据库：先更新 `database.sql`（保持 14 表约束、外键一致）
2. 后端：先补接口与校验（统一返回/异常/鉴权），再联调
3. 前端：按页面模块开发（先布局与样式，再接 API）
4. 自检：
   - 后端 `mvn test`
   - 前端 `npm run check && npm run lint && npm run build`

