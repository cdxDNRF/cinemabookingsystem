# cinema-frontend 页面设计说明（桌面端优先）

> 视觉与布局以你提供的截图为唯一基准：典型“控制台”结构（左侧深色侧边栏 + 顶部白色栏 + 内容区卡片/表格）。以下仅描述截图中可归纳出的结构与交互，不引入额外风格体系。

## 全局设计规范

### Layout
- 布局体系：Ant Design Layout 风格的三段式布局。
  - Sider：固定左侧，宽度约 200px（折叠态约 80px，若截图未体现折叠则默认不启用）。
  - Header：顶部固定/吸顶（以截图为准），高度约 56–64px。
  - Content：右侧主内容区，使用统一内边距（约 16–24px），内容以 Card + Table/Form 组织。
- 响应式：桌面端优先；在窄屏时允许 Sider 折叠为图标栏（仅当实现不破坏截图视觉时启用）。

### Meta Information（统一）
- title：Cinema
- description：影院业务系统（用户端/员工端/管理员端）
- Open Graph：og:title=Cinema；og:description=影院业务系统；og:type=website

### Global Styles（Token 建议，保持截图一致性）
- 字体：系统默认中文优先（PingFang SC / Microsoft YaHei），正文 14px，标题 16–20px。
- 主色：采用截图同款蓝色系（优先使用 UI 库默认 primary，避免自造偏差）。
- 背景：页面背景浅灰（content 外层），卡片背景纯白。
- 按钮：主要操作使用 Primary；次要操作使用 Default；危险操作使用 Danger（如删除/停用）。
- 表格：表头浅灰底；行 hover 高亮；空状态使用居中提示。

## 页面 1：登录页（/login）

### Page Structure
- 单页居中卡片结构：背景（浅色/渐变以截图为准）+ 登录 Card。

### Sections & Components
1. 顶部/Logo 区
   - 显示系统名/Logo（与侧边栏 Logo 保持一致）。
2. 登录表单 Card
   - 字段：账号、密码。
   - 主按钮：“登录”（loading 状态）。
   - 错误提示：表单项级校验 + 顶部/按钮附近的接口错误提示。
3. 登录后跳转
   - 成功：按 role 自动跳转到 /u 或 /staff 或 /admin。

## 页面 2：工作台壳（通用控制台布局：/u、/staff、/admin）

### Page Structure
- 左右结构：左侧 Sider 导航 + 右侧（Header + Content）。

### Sections & Components
1. Sider（左侧栏）
   - 顶部：Logo/系统名（与截图一致）。
   - 菜单：纵向 Menu，包含图标（若截图存在）。
   - 权限：根据 role 渲染不同菜单项；不可见即不可点。
2. Header（顶部栏）
   - 左侧：面包屑/当前模块标题（以截图为准）。
   - 右侧：当前用户信息（昵称/角色）+ 下拉菜单（至少包含“退出登录”）。
3. Content（内容区）
   - 使用 Card 承载筛选区与表格区。
   - 内边距与间距统一（与截图一致）。

## 页面 3：影片管理（/staff/movies、/admin/movies）与 影片浏览（/u/movies）

### Page Structure
- 顶部筛选区 + 中部表格/列表区。

### Sections & Components（管理端）
1. 筛选条（Card 顶部）
   - 关键字输入（影片名/编号等，字段以现有后端为准）。
   - 状态筛选（上架/下架等，若后端提供）。
   - 操作按钮：查询、重置。
2. 工具条
   - “新增影片”（仅 staff/admin，且仅当后端支持）。
3. 列表表格
   - 列：影片核心字段（名称、时长、状态、上映信息等以接口为准）。
   - 行操作：编辑、上下架/停用、删除（若接口提供）。

### Sections & Components（用户端）
- 同一内容区风格下，以列表/表格方式展示影片；点击进入场次与选座入口。

## 页面 4：场次管理（/staff/shows、/admin/shows）

### Page Structure
- 筛选区 + 场次表格。

### Sections & Components
1. 筛选区
   - 影片筛选、日期/时间范围（若后端支持）。
2. 工具条
   - 新增场次（若后端支持）。
3. 场次表格
   - 列：影片、影厅、开始时间、价格、状态、剩余座位等（以接口为准）。
   - 行操作：编辑/停用。

## 页面 5：选座下单（/u/booking/:showId）

### Page Structure
- 上方信息区（影片/场次摘要）+ 下方选座区（座位矩阵）+ 右侧或底部结算区（以截图布局风格对齐卡片化）。

### Sections & Components
1. 场次摘要 Card
   - 展示：影片名、影厅、时间、票价。
2. 座位图 Card
   - 座位状态：可选/不可选（已售）/已选。
   - 交互：点击切换选择；限制最大选座数；冲突时提示。
3. 结算区 Card
   - 显示已选座位、数量、总价。
   - 主按钮：提交订单。

## 页面 6：订单页（/u/orders、/staff/orders、/admin/orders）

### Page Structure
- 筛选区 + 订单表格（与截图表格视觉保持一致）。

### Sections & Components
1. 筛选区
   - 订单号/手机号/状态等（以接口为准）。
2. 订单表格
   - 用户端行操作：查看详情、取消（仅允许状态）。
   - 员工/管理员行操作：核销/检票（调用后端核销接口）。

## 页面 7：账号与权限管理（/admin/accounts，仅管理员）

### Page Structure
- 筛选区 + 账号表格。

### Sections & Components
1. 筛选区
   - 关键字（账号/姓名）、角色筛选、状态筛选。
2. 账号表格
   - 列：账号标识、角色、状态、创建时间等（以接口为准）。
   - 行操作：变更角色、启用/停用。
