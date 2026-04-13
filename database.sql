CREATE DATABASE IF NOT EXISTS cinema
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE cinema;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS t_order_seat;
DROP TABLE IF EXISTS t_order;
DROP TABLE IF EXISTS t_showing;
DROP TABLE IF EXISTS t_movie_staff;
DROP TABLE IF EXISTS t_movie_type_rel;
DROP TABLE IF EXISTS t_movie_user_action;
DROP TABLE IF EXISTS t_movie;
DROP TABLE IF EXISTS t_movie_type;
DROP TABLE IF EXISTS t_hall;
DROP TABLE IF EXISTS t_notice;
DROP TABLE IF EXISTS t_cinema_admin;
DROP TABLE IF EXISTS t_cinema;
DROP TABLE IF EXISTS t_user;
DROP TABLE IF EXISTS t_admin;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE t_admin (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  username VARCHAR(50) NOT NULL COMMENT '用户名',
  password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希（默认使用SHA-256十六进制）',
  nickname VARCHAR(50) NULL COMMENT '昵称',
  avatar_url VARCHAR(255) NULL COMMENT '头像URL',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用 0禁用',
  last_login_time DATETIME NULL COMMENT '最后登录时间',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_admin_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='超级管理员';

CREATE TABLE t_user (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  username VARCHAR(50) NOT NULL COMMENT '用户名',
  password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希（默认使用SHA-256十六进制）',
  nickname VARCHAR(50) NOT NULL COMMENT '昵称',
  phone VARCHAR(20) NULL COMMENT '手机号',
  avatar_url VARCHAR(255) NULL COMMENT '头像URL',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用 0禁用',
  last_login_time DATETIME NULL COMMENT '最后登录时间',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_username (username),
  KEY idx_user_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='普通用户';

CREATE TABLE t_cinema (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  name VARCHAR(100) NOT NULL COMMENT '影院名称',
  cover_url VARCHAR(255) NULL COMMENT '影院封面图URL',
  tags VARCHAR(255) NULL COMMENT '标签（逗号分隔，如WiFi覆盖,儿童优惠）',
  address VARCHAR(255) NOT NULL COMMENT '地址',
  phone VARCHAR(30) NULL COMMENT '电话',
  email VARCHAR(100) NULL COMMENT '邮箱',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1正常 0停用',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_cinema_name (name),
  KEY idx_cinema_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='影院信息';

CREATE TABLE t_cinema_admin (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  username VARCHAR(50) NOT NULL COMMENT '用户名',
  password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希（默认使用SHA-256十六进制）',
  real_name VARCHAR(50) NOT NULL COMMENT '真实姓名',
  id_card_no VARCHAR(30) NULL COMMENT '身份证号/证件号',
  phone VARCHAR(20) NULL COMMENT '手机号',
  email VARCHAR(100) NULL COMMENT '邮箱',
  cinema_id BIGINT NULL COMMENT '所属影院ID（审核通过后绑定）',
  audit_status TINYINT NOT NULL DEFAULT 0 COMMENT '审核状态：0待审核 1通过 2驳回',
  audit_reason VARCHAR(255) NULL COMMENT '驳回原因',
  audited_by_admin_id BIGINT NULL COMMENT '审核人（超级管理员）',
  audited_time DATETIME NULL COMMENT '审核时间',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用 0禁用',
  last_login_time DATETIME NULL COMMENT '最后登录时间',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_cinema_admin_username (username),
  KEY idx_cinema_admin_audit (audit_status),
  KEY idx_cinema_admin_cinema (cinema_id),
  CONSTRAINT fk_cinema_admin_cinema
    FOREIGN KEY (cinema_id) REFERENCES t_cinema (id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_cinema_admin_auditor
    FOREIGN KEY (audited_by_admin_id) REFERENCES t_admin (id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='影院管理员（注册+认证+审核）';

CREATE TABLE t_hall (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  cinema_id BIGINT NOT NULL COMMENT '影院ID',
  name VARCHAR(100) NOT NULL COMMENT '影厅名称',
  seat_rows INT NOT NULL DEFAULT 8 COMMENT '座位行数（默认8）',
  seat_cols INT NOT NULL DEFAULT 8 COMMENT '座位列数（默认8）',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用 0停用',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_hall_cinema_name (cinema_id, name),
  KEY idx_hall_cinema (cinema_id),
  CONSTRAINT fk_hall_cinema
    FOREIGN KEY (cinema_id) REFERENCES t_cinema (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='影厅（默认8x8）';

CREATE TABLE t_movie_type (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  name VARCHAR(50) NOT NULL COMMENT '类型名称',
  sort_no INT NOT NULL DEFAULT 0 COMMENT '排序',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用 0停用',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_movie_type_name (name),
  KEY idx_movie_type_sort (sort_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='电影类型';

CREATE TABLE t_movie (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  name VARCHAR(100) NOT NULL COMMENT '电影名称',
  name_en VARCHAR(150) NULL COMMENT '英文名',
  poster_url VARCHAR(255) NULL COMMENT '海报URL',
  region VARCHAR(50) NULL COMMENT '地区（筛选）',
  year INT NULL COMMENT '年代（筛选，如2024）',
  language VARCHAR(30) NULL COMMENT '语言',
  release_date DATE NULL COMMENT '上映日期',
  duration_min INT NULL COMMENT '时长（分钟）',
  intro TEXT NULL COMMENT '剧情简介',
  trailer_json TEXT NULL COMMENT '预告片JSON（数组：[{title,coverUrl,videoUrl,releaseTime}]）',
  status TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0待上映 1已上映 2下架',
  total_box_office DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT '累计票房（冗余缓存，来自已支付订单汇总）',
  rating_avg DECIMAL(3,1) NOT NULL DEFAULT 0.0 COMMENT '评分均值（冗余缓存）',
  rating_count INT NOT NULL DEFAULT 0 COMMENT '评分人数（冗余缓存）',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  KEY idx_movie_status (status),
  KEY idx_movie_release_date (release_date),
  KEY idx_movie_year (year),
  KEY idx_movie_region (region)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='电影信息';

CREATE TABLE t_movie_type_rel (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  movie_id BIGINT NOT NULL COMMENT '电影ID',
  type_id BIGINT NOT NULL COMMENT '类型ID',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_movie_type_rel (movie_id, type_id),
  KEY idx_movie_type_rel_type (type_id),
  CONSTRAINT fk_movie_type_rel_movie
    FOREIGN KEY (movie_id) REFERENCES t_movie (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_movie_type_rel_type
    FOREIGN KEY (type_id) REFERENCES t_movie_type (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='电影-类型关联（业务限制：1~3个类型）';

CREATE TABLE t_movie_staff (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  movie_id BIGINT NOT NULL COMMENT '电影ID',
  role_type TINYINT NOT NULL COMMENT '角色：1导演 2编剧 3主演 4其他',
  name VARCHAR(50) NOT NULL COMMENT '姓名',
  avatar_url VARCHAR(255) NULL COMMENT '头像URL',
  sort_no INT NOT NULL DEFAULT 0 COMMENT '排序',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  KEY idx_movie_staff_movie (movie_id),
  KEY idx_movie_staff_role (role_type),
  CONSTRAINT fk_movie_staff_movie
    FOREIGN KEY (movie_id) REFERENCES t_movie (id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='演职人员';

CREATE TABLE t_showing (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  cinema_id BIGINT NOT NULL COMMENT '影院ID',
  hall_id BIGINT NOT NULL COMMENT '影厅ID',
  movie_id BIGINT NOT NULL COMMENT '电影ID',
  start_time DATETIME NOT NULL COMMENT '放映开始时间',
  end_time DATETIME NOT NULL COMMENT '放映结束时间',
  ticket_price DECIMAL(10,2) NOT NULL COMMENT '票价（元）',
  submitter_cinema_admin_id BIGINT NOT NULL COMMENT '提交人（影院管理员）',
  audit_status TINYINT NOT NULL DEFAULT 0 COMMENT '审核状态：0待审核 1通过 2驳回 3下架',
  audited_by_admin_id BIGINT NULL COMMENT '审核人（超级管理员）',
  audited_time DATETIME NULL COMMENT '审核时间',
  audit_reason VARCHAR(255) NULL COMMENT '驳回/下架原因',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  KEY idx_showing_movie (movie_id),
  KEY idx_showing_cinema (cinema_id),
  KEY idx_showing_hall (hall_id),
  KEY idx_showing_start_time (start_time),
  KEY idx_showing_audit (audit_status),
  UNIQUE KEY uk_showing_hall_start (hall_id, start_time),
  CONSTRAINT fk_showing_cinema
    FOREIGN KEY (cinema_id) REFERENCES t_cinema (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_showing_hall
    FOREIGN KEY (hall_id) REFERENCES t_hall (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_showing_movie
    FOREIGN KEY (movie_id) REFERENCES t_movie (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_showing_submitter
    FOREIGN KEY (submitter_cinema_admin_id) REFERENCES t_cinema_admin (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_showing_auditor
    FOREIGN KEY (audited_by_admin_id) REFERENCES t_admin (id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='放映场次（影院提交->管理员审核）';

CREATE TABLE t_order (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  order_no VARCHAR(32) NOT NULL COMMENT '订单号',
  user_id BIGINT NOT NULL COMMENT '用户ID',
  showing_id BIGINT NOT NULL COMMENT '场次ID',
  cinema_id BIGINT NOT NULL COMMENT '影院ID（冗余）',
  hall_id BIGINT NOT NULL COMMENT '影厅ID（冗余）',
  movie_id BIGINT NOT NULL COMMENT '电影ID（冗余）',
  seat_count INT NOT NULL COMMENT '座位数量',
  total_amount DECIMAL(10,2) NOT NULL COMMENT '总金额（元）',
  status TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0待支付(锁座中) 1待取票(已支付) 2已完成 3已取消 4已超时取消',
  lock_expire_time DATETIME NULL COMMENT '锁座到期时间（待支付状态有效）',
  pay_time DATETIME NULL COMMENT '支付时间',
  cancel_time DATETIME NULL COMMENT '取消时间',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_order_no (order_no),
  KEY idx_order_user (user_id),
  KEY idx_order_showing (showing_id),
  KEY idx_order_status (status),
  KEY idx_order_lock_expire (lock_expire_time),
  CONSTRAINT fk_order_user
    FOREIGN KEY (user_id) REFERENCES t_user (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_order_showing
    FOREIGN KEY (showing_id) REFERENCES t_showing (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_order_cinema
    FOREIGN KEY (cinema_id) REFERENCES t_cinema (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_order_hall
    FOREIGN KEY (hall_id) REFERENCES t_hall (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_order_movie
    FOREIGN KEY (movie_id) REFERENCES t_movie (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='购票订单主表（含锁座）';

CREATE TABLE t_order_seat (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  order_id BIGINT NOT NULL COMMENT '订单ID',
  seat_row INT NOT NULL COMMENT '座位行（1..8）',
  seat_col INT NOT NULL COMMENT '座位列（1..8）',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_order_seat (order_id, seat_row, seat_col),
  KEY idx_order_seat_order (order_id),
  CONSTRAINT fk_order_seat_order
    FOREIGN KEY (order_id) REFERENCES t_order (id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单座位明细（二层展开）';

CREATE TABLE t_notice (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  title VARCHAR(150) NOT NULL COMMENT '公告标题',
  content TEXT NOT NULL COMMENT '公告内容',
  publish_status TINYINT NOT NULL DEFAULT 0 COMMENT '发布状态：0草稿 1已发布 2已下线',
  publish_time DATETIME NULL COMMENT '发布时间',
  publisher_admin_id BIGINT NULL COMMENT '发布人（超级管理员）',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  KEY idx_notice_status (publish_status),
  KEY idx_notice_publish_time (publish_time),
  CONSTRAINT fk_notice_publisher
    FOREIGN KEY (publisher_admin_id) REFERENCES t_admin (id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统公告';

CREATE TABLE t_movie_user_action (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  user_id BIGINT NOT NULL COMMENT '用户ID',
  movie_id BIGINT NOT NULL COMMENT '电影ID',
  is_favorite TINYINT NOT NULL DEFAULT 0 COMMENT '是否收藏：1是 0否',
  favorite_time DATETIME NULL COMMENT '收藏时间',
  score INT NULL COMMENT '评分（1-10）',
  score_time DATETIME NULL COMMENT '评分时间',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_movie (user_id, movie_id),
  KEY idx_action_movie (movie_id),
  KEY idx_action_favorite (is_favorite),
  KEY idx_action_score (score),
  CONSTRAINT fk_action_user
    FOREIGN KEY (user_id) REFERENCES t_user (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_action_movie
    FOREIGN KEY (movie_id) REFERENCES t_movie (id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户收藏/评分（合并表）';

INSERT INTO t_admin (id, username, password_hash, nickname, avatar_url, status, last_login_time)
VALUES
  (1, 'admin', SHA2('123456', 256), '管理员', NULL, 1, NULL);

INSERT INTO t_user (id, username, password_hash, nickname, phone, avatar_url, status, last_login_time)
VALUES
  (1, 'zhangsan', SHA2('123456', 256), '张三', '18800000001', NULL, 1, NULL),
  (2, 'lisi', SHA2('123456', 256), '李四', '18800000002', NULL, 1, NULL);

INSERT INTO t_cinema (id, name, cover_url, tags, address, phone, email, status)
VALUES
  (1, '万象城影城', NULL, '温度较低,儿童优惠,WiFi覆盖', '合肥市蜀山区滨湖大道东方银座·示例地址1', '18899990000', 'wxc@163.com', 1),
  (2, '万达影城', NULL, 'WiFi覆盖', '合肥市示例地址2', '19900001112', 'xiaoming@xm.com', 1),
  (3, '奥斯卡电影城', NULL, '停车位充足,WiFi覆盖', '合肥市示例地址3', '18506806883', '305449517@qq.com', 1),
  (4, '丁丁影城（乐客莱店）', NULL, '儿童优惠', '合肥市示例地址4', '0551-62633966', NULL, 1);

INSERT INTO t_cinema_admin (id, username, password_hash, real_name, id_card_no, phone, email, cinema_id, audit_status, audit_reason, audited_by_admin_id, audited_time, status)
VALUES
  (1, 'cinema1', SHA2('123456', 256), '李四', '340000199901010011', '18800001001', 'cinema1@xm.com', 1, 1, NULL, 1, NOW(), 1),
  (2, 'cinema2', SHA2('123456', 256), '王五', '340000199901010022', '18800001002', 'cinema2@xm.com', NULL, 0, NULL, NULL, NULL, 1);

INSERT INTO t_hall (id, cinema_id, name, seat_rows, seat_cols, status)
VALUES
  (1, 1, '一号厅', 8, 8, 1),
  (2, 1, '二号厅', 8, 8, 1),
  (3, 1, '三号厅', 8, 8, 1),
  (4, 2, '一号厅', 8, 8, 1),
  (5, 3, '二号厅', 8, 8, 1),
  (6, 4, '四号厅', 8, 8, 1);

INSERT INTO t_movie_type (id, name, sort_no, status)
VALUES
  (1, '剧情', 1, 1),
  (2, '动作', 2, 1),
  (3, '科幻', 3, 1),
  (4, '战争', 4, 1),
  (5, '动画', 5, 1),
  (6, '喜剧', 6, 1),
  (7, '爱情', 7, 1),
  (8, '悬疑', 8, 1),
  (9, '纪录', 9, 1),
  (10, '冒险', 10, 1),
  (11, '历史', 11, 1),
  (12, '犯罪', 12, 1);

INSERT INTO t_movie (id, name, name_en, poster_url, region, year, language, release_date, duration_min, intro, trailer_json, status, total_box_office, rating_avg, rating_count)
VALUES
  (1, '熊猫计划', 'Panda Plan', NULL, '中国大陆', 2024, '中文', '2024-11-01', 110, '一场关于守护与成长的奇妙冒险。', '[{"title":"预告片1","coverUrl":null,"videoUrl":null,"releaseTime":"2024-11-01 10:00:00"}]', 1, 435.80, 4.0, 12),
  (2, '毒液：最后一舞', 'VENOM: THE LAST DANCE', NULL, '美国', 2024, '英文', '2024-11-01', 109, '黑暗共生体的最终抉择。', '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2024-11-06 16:31:46"}]', 1, 276.50, 9.0, 21),
  (3, '志愿军：存亡之战', NULL, NULL, '中国大陆', 2024, '中文', '2024-11-01', 144, '烽火岁月中的信念与牺牲。', '[]', 1, 247.50, 9.5, 30),
  (4, '海绵宝宝：拯救比奇堡', NULL, NULL, '美国', 2024, '英文', '2024-10-30', 95, '比奇堡危机来袭，海绵宝宝踏上拯救之旅。', '[]', 1, 238.40, 6.0, 8),
  (5, '变形金刚：起源', NULL, NULL, '美国', 2024, '英文', '2024-09-01', 120, '钢铁之躯的起源故事。', '[]', 1, 195.80, 7.5, 15),
  (6, '爱情神话', NULL, NULL, '中国大陆', 2024, '中文', '2024-10-30', 112, '关于爱情与生活的温柔叙事。', '[]', 1, 59.60, 10.0, 6),
  (7, '伟大征程', 'THE GREAT JOURNEY', NULL, '中国大陆', 2025, '中文', '2025-07-02', 126, '时代洪流中的人物群像。', '[]', 0, 0.00, 10.0, 3),
  (8, '红色一号：冬日行动', 'RED ONE', NULL, '美国', 2025, '英文', '2025-07-01', 123, '冬日行动拉开序幕。', '[]', 0, 0.00, 0.0, 0),
  (9, '749局', NULL, NULL, '中国大陆', 2024, '中文', '2024-11-01', 118, '神秘机构背后的故事。', '[]', 1, 0.00, 1.0, 1);

INSERT INTO t_movie_type_rel (movie_id, type_id)
VALUES
  (1, 5), (1, 6),
  (2, 2), (2, 3),
  (3, 1), (3, 4),
  (4, 5), (4, 10),
  (5, 2), (5, 3),
  (6, 7), (6, 1),
  (7, 11), (7, 1),
  (8, 10), (8, 6),
  (9, 8), (9, 3);

INSERT INTO t_movie_staff (movie_id, role_type, name, avatar_url, sort_no)
VALUES
  (2, 1, '导演A', NULL, 1),
  (2, 2, '编剧A', NULL, 2),
  (2, 3, '主演A', NULL, 3),
  (3, 3, '张译', NULL, 1),
  (3, 3, '黄晓明', NULL, 2);

INSERT INTO t_showing (id, cinema_id, hall_id, movie_id, start_time, end_time, ticket_price, submitter_cinema_admin_id, audit_status, audited_by_admin_id, audited_time, audit_reason)
VALUES
  (1, 1, 3, 3, '2024-11-09 06:00:00', '2024-11-09 08:30:00', 49.50, 1, 1, 1, NOW(), NULL),
  (2, 1, 1, 3, '2024-11-09 06:00:00', '2024-11-09 08:30:00', 49.50, 1, 1, 1, NOW(), NULL),
  (3, 4, 6, 2, '2024-11-10 21:00:00', '2024-11-10 23:00:00', 39.50, 1, 1, 1, NOW(), NULL);

INSERT INTO t_notice (id, title, content, publish_status, publish_time, publisher_admin_id)
VALUES
  (1, '系统公告：欢迎使用电影购票系统', '为确保良好体验，请合理安排观影时间并遵守影院规定。', 1, NOW(), 1);

INSERT INTO t_movie_user_action (user_id, movie_id, is_favorite, favorite_time, score, score_time)
VALUES
  (1, 2, 1, NOW(), 9, NOW()),
  (1, 1, 1, NOW(), 4, NOW()),
  (2, 6, 0, NULL, 10, NOW());

INSERT INTO t_order (id, order_no, user_id, showing_id, cinema_id, hall_id, movie_id, seat_count, total_amount, status, lock_expire_time, pay_time, cancel_time)
VALUES
  (1, '1731234619432', 1, 3, 4, 6, 2, 4, 158.00, 1, NULL, '2024-11-10 21:05:00', NULL),
  (2, '1731047550050', 2, 1, 1, 3, 3, 1, 49.50, 3, NULL, NULL, '2024-11-09 05:50:00'),
  (3, '1731235320888', 2, 2, 1, 1, 3, 2, 99.00, 0, DATE_ADD(NOW(), INTERVAL 10 MINUTE), NULL, NULL);

INSERT INTO t_order_seat (order_id, seat_row, seat_col)
VALUES
  (1, 6, 6), (1, 6, 7), (1, 6, 8), (1, 5, 7),
  (2, 3, 3),
  (3, 8, 7), (3, 8, 8);

SET FOREIGN_KEY_CHECKS = 1;

