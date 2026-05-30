# 电影购票网站（仿猫眼电影）

本仓库是一个**前后端完全分离**的电影购票系统，包含三种角色：

- 超级管理员（Admin）
- 影院管理员（Cinema Admin）
- 普通用户（User）

并实现：多影院、多影厅、多场次排期管理；在线 8×8 选座（锁座/超时释放）；ECharts 数据统计；预告片视频播放；订单二层展开座位信息；用户注册与账户管理；影院管理员审核流程等。

***

## 技术栈

- **后端**：Spring Boot 3 + MyBatis + Hutool + Lombok + MySQL
- **前端**：Vue 3 + TypeScript + Element-Plus + Vue-Router + Axios + Pinia + ECharts
- **数据库**：MySQL 5.7 / 8.0（建议 8.0）
- **JDK**：>= 17
- **Node.js**：>= 18
- **Maven**：>= 3.8

***

## 项目结构

```
cinemabookingsystem/
├── cinema-backend/          # 后端工程（REST API）
├── cinema-frontend/         # 前端工程（Vite + Vue3）
├── database.sql             # 数据库脚本（14 张表 + 外键 + 初始化数据）
├── README.md                # 项目说明文档（本文档）
├── 项目汇报文档.md           # 详细技术汇报文档
└── 新手解读文档.md           # 零基础入门解读
```

***

## 数据库（14 张表）

所有表均使用：`t_` 前缀 + `utf8mb4_unicode_ci` 字符集。

### 导入方式

1. 启动 MySQL
2. 创建数据库：

```sql
CREATE DATABASE IF NOT EXISTS cinema CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cinema;
```

1. 执行根目录的 `database.sql`：

```sql
source /path/to/database.sql;
```

> **注意**：`database.sql` 已包含完整的表结构、约束、索引和示例数据（含 30 部电影、3 个影院、多个影厅和排期）。

***

## 本地启动

### 0）前置条件

- MySQL 已启动，可连接（默认连接 `127.0.0.1:3306`）
- 已创建 `cinema` 数据库并导入 `database.sql`

### 1）启动后端（cinema-backend）

后端默认端口：`8080`

#### 配置本地数据库连接

1. 复制配置模板：

```bash
cp cinema-backend/src/main/resources/application-local.example.yml \
   cinema-backend/src/main/resources/application-local.yml
```

1. 修改 `application-local.yml`：

- `spring.datasource.username` / `password` —— 你的 MySQL 账号密码
- `cinema.jwt.secret` —— JWT 密钥（建议修改为随机字符串）

> ⚠️ **重要**：`application-local.yml` 包含敏感信息，**不要提交到 Git**（已在 `.gitignore` 中排除）。

#### 启动服务

```bash
cd cinema-backend
mvn spring-boot:run
```

启动成功后：

- API 基地址：`http://localhost:8080/api`

### 2）启动前端（cinema-frontend）

前端默认端口：`5173`

```bash
cd cinema-frontend
npm install
npm run dev
```

访问：`http://127.0.0.1:5173/`

> 开发环境已在 `vite.config.ts` 配好代理：`/api -> http://localhost:8080`

***

## 测试账号

初始化数据在 `database.sql` 中。

### 超级管理员（Admin）

- 用户名：`admin`
- 密码：`123456`

### 普通用户（User）

- 用户名：`zhangsan` / `lisi`
- 密码：`123456`

### 影院管理员（Cinema Admin）

- 已审核通过：用户名 `cinema1`，密码 `123456`
- 待审核：用户名 `cinema2`，密码 `123456`

***

## 主要功能模块

### 普通用户端

- 浏览电影首页、电影列表、电影详情
- 按类型 / 年代 / 地区筛选电影
- 查看排期、在线选座购票
- 收藏电影、评分评论
- 查看我的订单、取消待支付订单
- 用户注册、账户注销

### 影院管理员端

- 影院信息管理
- 影厅增删改查
- 排期管理（添加 / 编辑 / 删除 / 冲突检测）
- 查看本影院订单

### 超级管理员端

- 影院入驻审核
- 电影信息管理（CRUD、类型、演职人员）
- 全局排期审核与管理
- 订单管理
- 数据统计（ECharts 图表）
- 系统公告发布
- 账号管理（用户 / 影院管理员 / 管理员）

***

## 关键特性

| 特性          | 说明                                   |
| ----------- | ------------------------------------ |
| **三角色权限体系** | 基于 JWT + 自定义注解的声明式权限控制               |
| **排期冲突检测**  | 同一影厅同一时间段不可重复排期                      |
| **在线选座锁座**  | 8×8 座位图，下单锁定 10 分钟，超时自动释放            |
| **数据可视化**   | ECharts 展示票房趋势、类型分布、影院排行等            |
| **真实电影海报**  | 通过 TMDB API 获取真实海报 URL，带默认图 fallback |
| **前后端分离**   | 独立开发、独立部署，RESTful API 通信             |

***

## 文档索引

| 文档                     | 说明                       |
| ---------------------- | ------------------------ |
| [README.md](README.md) | 项目简介与快速启动指南（本文档）         |
| [项目汇报文档.md](项目汇报文档.md) | 详细技术架构、数据库设计、API 设计、项目结构 |
| [新手解读文档.md](新手解读文档.md) | 零基础友好版解读，通俗解释技术概念        |

***

## 许可证

本项目仅供学习交流使用。
