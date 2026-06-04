# 影院管理系统

## 项目简介

本项目是一个仿猫眼电影的在线购票系统，采用前后端完全分离的架构设计。系统支持三种角色：普通用户、影院管理员和超级管理员，涵盖电影浏览、选座购票、排片管理、数据统计等完整业务流程。

## 技术栈

### 后端
- **Spring Boot 3.3.5** —— Java 企业级应用框架
- **MyBatis 3.0.3** —— 持久层框架
- **MySQL 8.0+** —— 关系型数据库
- **JWT** —— 身份认证
- **Maven** —— 项目构建工具
- **Java 17**

### 前端
- **Vue 3.4+** —— 渐进式 JavaScript 框架
- **TypeScript** —— 类型安全的 JavaScript 超集
- **Vite 5** —— 前端构建工具
- **Element Plus** —— UI 组件库
- **Tailwind CSS** —— 原子化 CSS 框架
- **Pinia** —— 状态管理
- **ECharts** —— 数据可视化图表
- **Axios** —— HTTP 客户端

## 项目结构

```
cinema-backend/          # 后端项目
├── src/main/java/com/xd/cinema/
│   ├── auth/            # 认证相关（登录、注册）
│   ├── common/          # 公共组件（安全、异常、工具）
│   ├── config/          # 配置类
│   └── module/          # 业务模块
│       ├── movie/       # 电影管理
│       ├── order/       # 订单管理
│       ├── cinema/      # 影院管理
│       ├── showing/     # 排片管理
│       ├── user/        # 用户管理
│       └── action/      # 用户行为（评分、收藏、评论）
└── src/main/resources/
    ├── mapper/          # MyBatis XML 映射文件
    └── application.yml  # 应用配置

cinema-frontend/         # 前端项目
├── src/
│   ├── api/             # API 接口封装
│   ├── pages/           # 页面组件
│   │   ├── user/        # 用户端页面
│   │   ├── staff/       # 影院管理员页面
│   │   └── admin/       # 超级管理员页面
│   ├── router/          # 路由配置
│   ├── stores/          # Pinia 状态管理
│   ├── layouts/         # 布局组件
│   └── components/      # 公共组件
├── public/posters/      # 电影海报资源
└── package.json
```

## 快速启动

### 环境要求

- MySQL 8.0+
- Maven 3.8+
- Node.js 18+

### 1. 启动 MySQL

```powershell
Start-Service MySQL80
```

### 2. 启动后端

```powershell
cd cinema-backend
mvn spring-boot:run
```

等待出现 `Started CinemaBackendApplication` 即启动成功，服务运行在 http://localhost:8080。

### 3. 启动前端

**新开一个 PowerShell 窗口：**

```powershell
cd cinema-frontend
npm run dev
```

等待出现 `VITE v5.x ready` 即启动成功。

### 4. 访问系统

浏览器打开 http://localhost:5173

## 测试账号

| 角色 | 账号 | 密码 |
|------|------|------|
| 超级管理员 | admin | 123456 |
| 普通用户 | zhangsan | 123456 |
| 影院管理员 | cinema1 | 123456 |

## 核心功能

- **用户端**：电影浏览、搜索筛选、预告片播放、选座购票、订单管理、评分评论
- **影院管理员**：影院信息管理、影厅管理、排片安排（自动冲突检测）、订单查看
- **超级管理员**：影院审核、电影管理、排片审核、数据统计（ECharts 图表）、公告管理、账号管理

## 数据库

- 共 14 张表，涵盖用户、影院、电影、排片、订单、评论等完整业务
- 支持冗余缓存（电影评分、票房）提升查询性能
- 订单锁座机制，10 分钟未支付自动释放座位

## 相关文档

- [启动指南](./启动.md) —— 详细的启动步骤说明
- [新手解读文档](./新手解读文档.md) —— 零基础理解项目架构与技术
- [开发问题记录](./issue.md) —— 开发过程中遇到的难点与解决方案

## 许可证

MIT
