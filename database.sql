-- 请根据需要修改数据库名称
-- CREATE DATABASE IF NOT EXISTS cinema CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE cinema;

-- 如果数据库已存在，先删除并重新创建（开发环境使用）
-- DROP DATABASE IF EXISTS cinema;
-- CREATE DATABASE cinema CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE cinema;

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
  content TEXT NULL COMMENT '评论内容',
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户收藏/评分/评论（合并表）';

-- ============================================================
-- 基础数据插入
-- ============================================================

INSERT INTO t_admin (id, username, password_hash, nickname, avatar_url, status, last_login_time)
VALUES
  (1, 'admin', SHA2('123456', 256), '管理员', NULL, 1, NULL);

INSERT INTO t_user (id, username, password_hash, nickname, phone, avatar_url, status, last_login_time)
VALUES
  (1, 'zhangsan', SHA2('123456', 256), '张三', '18800000001', NULL, 1, NULL),
  (2, 'lisi', SHA2('123456', 256), '李四', '18800000002', NULL, 1, NULL),
  (3, 'wangwu', SHA2('123456', 256), '王五', '18800000003', NULL, 1, NULL),
  (4, 'zhaoliu', SHA2('123456', 256), '赵六', '18800000004', NULL, 1, NULL),
  (5, 'qianqi', SHA2('123456', 256), '钱七', '18800000005', NULL, 1, NULL),
  (6, 'sunba', SHA2('123456', 256), '孙八', '18800000006', NULL, 1, NULL),
  (7, 'zhoujiu', SHA2('123456', 256), '周九', '18800000007', NULL, 1, NULL),
  (8, 'wushi', SHA2('123456', 256), '吴十', '18800000008', NULL, 1, NULL),
  (9, 'zheng11', SHA2('123456', 256), '郑十一', '18800000009', NULL, 1, NULL),
  (10, 'feng12', SHA2('123456', 256), '冯十二', '18800000010', NULL, 1, NULL),
  (11, 'chen13', SHA2('123456', 256), '陈十三', '18800000011', NULL, 1, NULL),
  (12, 'chu14', SHA2('123456', 256), '褚十四', '18800000012', NULL, 1, NULL);

INSERT INTO t_cinema (id, name, cover_url, tags, address, phone, email, status)
VALUES
  (1, '万象城影城', NULL, '温度较低,儿童优惠,WiFi覆盖', '合肥市蜀山区滨湖大道东方银座', '18899990000', 'wxc@163.com', 1),
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

-- ============================================================
-- 30部电影数据（含海报路径、简介、演职人员）
-- ============================================================
INSERT INTO t_movie (id, name, name_en, poster_url, region, year, language, release_date, duration_min, intro, trailer_json, status, total_box_office, rating_avg, rating_count)
VALUES
  (1, '哪吒之魔童闹海', 'Ne Zha 2', 'https://image.tmdb.org/t/p/w500/cb5NyNrqiCNNoDkA8FfxHAtypdG.jpg', '中国大陆', 2025, '中文', '2025-01-29', 144, 
   '天劫之后，哪吒和敖丙的灵魂虽然保住，但肉身很快会魂飞魄散。太乙真人打算用七色宝莲给二人重塑肉身，但是在重塑肉身的过程中却遇到重重困难。哪吒、敖丙的命运将走向何方？', 
   'BV1ULFPeEEBh', 1, 1544615.00, 8.5, 1250000),
  (2, '唐探1900', 'DETECTIVE CHINATOWN 1900', 'https://image.tmdb.org/t/p/w500/g3GsgIlH3fA4RxhNOAMvSbVWyfW.jpg', '中国大陆', 2025, '中文', '2025-01-29', 136, 
   '1900年，在美国旧金山唐人街，华裔印第安猎人阿鬼（王宝强 饰）与留美青年秦福（刘昊然 饰）因一场凶杀案偶然结识，误打误撞组成"唐人街神探"组合，开启了一场笑闹探案之旅。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2025-01-29 10:00:00"}]', 1, 361251.00, 7.2, 580000),
  (3, '封神第二部：战火西岐', 'Creation of the Gods II', 'https://image.tmdb.org/t/p/w500/dfUCs5HNtGu4fofh83uiE2Qcy3v.jpg', '中国大陆', 2025, '中文', '2025-01-29', 144, 
   '姜子牙、姬发带队坚守西岐，家园保卫战一触即发！邓婵玉、闻仲奉商王殷寿之命，率魔家四将等殷商大军征伐西岐，西岐一方得殷郊、雷震子、杨戬、哪吒等相助，更聚全民之力守卫家园。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2025-01-29 10:00:00"}]', 1, 120000.00, 5.9, 420000),
  (4, '射雕英雄传：侠之大者', 'The Legend of the Condor Heroes', 'https://image.tmdb.org/t/p/w500/wFc9q0aukqLipT1Oyt1fk4udjyV.jpg', '中国大陆', 2025, '中文', '2025-01-29', 146, 
   '恩怨情仇的江湖，权势角力的战乱时代，郭靖（肖战 饰）童年离别家乡，逐渐炼就可改变局面和命运的庞大力量，虽受高人赏识和器重，得传天下绝世武功"九阴真经"和"降龙十八掌"，却惹来各方嫉忌。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2025-01-29 10:00:00"}]', 1, 67000.00, 5.5, 380000),
  (5, '熊出没·重启未来', 'Boonie Bears: Future Reborn', 'https://image.tmdb.org/t/p/w500/2KQMmKP76xJs2aZyTQIJ1Xm2gny.jpg', '中国大陆', 2025, '中文', '2025-01-29', 108, 
   '光头强、熊大、熊二意外穿越到100年后的未来世界，此时的地球已被孢子植物全面侵占，人类在末日中艰难求生。为了回到自己的时代，三人组必须联手拯救这个破败的未来世界。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2025-01-29 10:00:00"}]', 1, 82000.00, 7.8, 320000),
  (6, '热辣滚烫', 'YOLO', 'https://image.tmdb.org/t/p/w500/ayVpd24FepJa5WXXgBbrGwC2Io0.jpg', '中国大陆', 2024, '中文', '2024-02-10', 129, 
   '乐莹（贾玲 饰）宅家多年，无所事事。大学毕业工作了一段时间后，乐莹选择脱离社会，封闭社交圈层，这是她认为与自己"和解"的最好方式。一日，在命运的几番"捉弄"下，她决定要换一种方式生活。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2024-02-10 10:00:00"}]', 1, 341757.00, 7.6, 890000),
  (7, '飞驰人生2', 'Pegasus 2', 'https://image.tmdb.org/t/p/w500/tYCsMelHCecCvhWsrvR9NsZcT1D.jpg', '中国大陆', 2024, '中文', '2024-02-10', 121, 
   '昔日冠军车手张驰（沈腾 饰）沦为落魄驾校教练，过着靠脸吃饭勉强度日的生活。不料天上掉馅饼，濒临停产的老头乐车厂厂长（贾冰 饰）主动提出赞助张驰组建车队再闯最后一届巴音布鲁克拉力赛。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2024-02-10 10:00:00"}]', 1, 336118.00, 7.7, 760000),
  (8, '周处除三害', 'The Pig, The Snake and The Pigeon', 'https://image.tmdb.org/t/p/w500/9FhZ9VC999qeOWH2ytbangUMMt4.jpg', '中国台湾', 2024, '中文', '2024-03-01', 134, 
   '通缉犯陈桂林（阮经天 饰）生命将尽，却发现自己在通缉榜上只排名第三，他决心查出前两名通缉犯的下落，并将他们一一除掉。陈桂林以为自己已成为当代的周处除三害，却没想到永远参不透的贪嗔痴，才是人生终要面对的罪与罚。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2024-03-01 10:00:00"}]', 1, 66500.00, 8.1, 650000),
  (9, '流浪地球3', 'The Wandering Earth 3', 'https://image.tmdb.org/t/p/w500/7pNAki9AIaJGhNFOs8ePTFI0lDc.jpg', '中国大陆', 2025, '中文', '2025-02-01', 148, 
   '太阳即将毁灭，人类在地球表面建造出巨大的推进器，寻找新的家园。然而宇宙之路危机四伏，为了拯救地球，流浪地球时代的年轻人再次挺身而出，展开争分夺秒的生死之战。', 
   'BV1Fa4y1973i', 1, 402900.00, 7.8, 450000),
  (10, '满江红', 'Full River Red', 'https://image.tmdb.org/t/p/w500/kOoxkXTYTi4OipM5G97gK9jnYIk.jpg', '中国大陆', 2023, '中文', '2023-01-22', 159, 
   '南宋绍兴年间，岳飞死后四年，秦桧率兵与金国会谈。会谈前夜，金国使者死在宰相驻地，所携密信也不翼而飞。小兵张大（沈腾 饰）与亲兵营副统领孙均（易烊千玺 饰）机缘巧合被裹挟进这巨大阴谋之中。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2023-01-22 10:00:00"}]', 1, 454444.00, 7.1, 920000),
  (11, '深海', 'Deep Sea', 'https://image.tmdb.org/t/p/w500/yIuyHCFijTkL8oRONSgZHWbFJp9.jpg', '中国大陆', 2023, '中文', '2023-01-22', 112, 
   '在大海的最深处，藏着所有秘密。一位少女在神秘海底世界追寻探索，邂逅一段独特生命旅程。影片采用首创的"粒子水墨"技术，将中国传统水墨画与三维动画技术相结合，呈现出前所未见的视觉效果。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2023-01-22 10:00:00"}]', 1, 91900.00, 7.2, 380000),
  (12, '长安三万里', 'Chang An', 'https://image.tmdb.org/t/p/w500/ltWuj0bEhITpiNYaTmpc2lUKy90.jpg', '中国大陆', 2023, '中文', '2023-07-08', 168, 
   '安史之乱爆发后数年，吐蕃大军攻打西南。大唐节度使高适交战不利，长安岌岌可危。困守孤城的高适向监军太监回忆起自己与李白的一生往事。影片以诗仙李白和高适的友情为主线，展现盛唐诗人群像。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2023-07-08 10:00:00"}]', 1, 182446.00, 8.3, 520000),
  (13, '八角笼中', 'Never Say Never', 'https://image.tmdb.org/t/p/w500/xj8JmcJhqShEm5pdBCpOevAjFzE.jpg', '中国大陆', 2023, '中文', '2023-07-06', 117, 
   '向腾辉（王宝强 饰）倾注心血想把当地无人照料的孩子培养成才，这让生活本没有出路的孩子们看到了一丝通向未来的曙光。然而，随着往日的表演视频被爆出，这些"残忍、血腥"的画面刺激了不明真相的人们的神经。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2023-07-06 10:00:00"}]', 1, 220740.00, 7.4, 680000),
  (14, '消失的她', 'Lost in the Stars', 'https://image.tmdb.org/t/p/w500/88zdJKhD42Mpnd3if4RXYyILT9P.jpg', '中国大陆', 2023, '中文', '2023-06-22', 121, 
   '何非（朱一龙 饰）的妻子李木子在结婚周年旅行中离奇消失，在何非苦寻无果之时妻子再次现身，何非却坚持眼前的陌生女人并非妻子，妻子拿出了身份证明进行自证，夫妻二人似乎都有不可告人的秘密。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2023-06-22 10:00:00"}]', 1, 352398.00, 6.5, 850000),
  (15, '孤注一掷', 'No More Bets', 'https://image.tmdb.org/t/p/w500/3GPgQAzJRmbsrd3UvnkBJikefzp.jpg', '中国大陆', 2023, '中文', '2023-08-08', 130, 
   '程序员潘生（张艺兴 饰）、模特安娜（金晨 饰）被海外高薪招聘吸引，出国淘金，却意外落入境外诈骗工厂的陷阱。为了离开，两人准备向赌徒阿天（王大陆 饰）和其女友小雨（周也 饰）下手，从他们身上套现、完成业绩。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2023-08-08 10:00:00"}]', 1, 384984.00, 7.0, 720000),
  (16, '沙丘2', 'Dune: Part Two', 'https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg', '美国', 2024, '英文', '2024-03-08', 166, 
   '保罗·厄崔迪公爵加入了弗雷曼人阵营，开始成为他们的精神领袖，并决心对毁灭他家族的阴谋者进行报复。面对一生挚爱和已知宇宙命运之间的抉择，他必须努力阻止只有他能预见的可怕未来。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2024-03-08 10:00:00"}]', 1, 35200.00, 8.2, 520000),
  (17, '哥斯拉大战金刚2：帝国崛起', 'Godzilla x Kong: The New Empire', 'https://image.tmdb.org/t/p/w500/z1p34vh7dEOnLDmyCrlUVLuoDzd.jpg', '美国', 2024, '英文', '2024-03-29', 115, 
   '继上一次的怪兽高燃对战之后，金刚和哥斯拉将再度联手对抗一个潜伏在世界深处的巨大威胁，并逐步探索这些巨兽们的起源以及骷髅岛等地的奥秘。同时，上古之战的面纱也将会被揭晓。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2024-03-29 10:00:00"}]', 1, 95600.00, 6.8, 380000),
  (18, '功夫熊猫4', 'Kung Fu Panda 4', 'https://image.tmdb.org/t/p/w500/kDp1vUBnMpe8ak4rjgl3cLELqjU.jpg', '美国/中国大陆', 2024, '英文', '2024-03-22', 94, 
   '神龙大侠阿宝（杰克·布莱克 配音）再度归来，要被师父（达斯汀·霍夫曼 配音）强行进阶修行。全新最强反派魅影妖后（维奥拉·戴维斯 配音）登场，神秘莫测的她可以幻化成每一个阿宝的昔日宿敌。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2024-03-22 10:00:00"}]', 1, 37300.00, 6.5, 290000),
  (19, '异形：夺命舰', 'Alien: Romulus', 'https://image.tmdb.org/t/p/w500/2uSWRTtCG336nuBiG8jOTEUKSy8.jpg', '美国', 2024, '英文', '2024-08-16', 119, 
   '影片时间线设定在1979年第一部《异形》与1986年的续集《异形2》之间，围绕一群年轻而勇敢的太空殖民者展开。讲述他们为逃离外星采矿殖民地的沉闷生活，在冒险探索一座废弃的太空站时，意外遭遇了宇宙中最可怕的生命体——异形。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2024-08-16 10:00:00"}]', 1, 78600.00, 7.4, 420000),
  (20, '奥本海默', 'Oppenheimer', 'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg', '美国', 2023, '英文', '2023-07-21', 180, 
   '克里斯托弗·诺兰自编自导的二战题材传记电影，聚焦美国"原子弹之父"罗伯特·奥本海默。影片讲述了奥本海默领导曼哈顿计划，研制出世界上第一颗原子弹的故事，以及他在战后遭受的政治迫害。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2023-07-21 10:00:00"}]', 1, 45000.00, 8.8, 680000),
  (21, '芭比', 'Barbie', 'https://image.tmdb.org/t/p/w500/iuFNMS8U5cb6xfzi51Dbkovj7vM.jpg', '美国', 2023, '英文', '2023-07-21', 114, 
   '在芭比乐园里，各种各样的芭比和肯每天都过着童话般100%完美的生活。但是某一天，芭比（玛格特·罗比 饰）发现自己的生活开始出现不完美，她决定前往真实世界探寻真相，肯（瑞恩·高斯林 饰）也一路跟随。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2023-07-21 10:00:00"}]', 1, 25200.00, 7.9, 520000),
  (22, '银河护卫队3', 'Guardians of the Galaxy Vol. 3', 'https://image.tmdb.org/t/p/w500/r2J02Z2OpNTctfOSN1Ydgii51I3.jpg', '美国', 2023, '英文', '2023-05-05', 150, 
   '影片承接前作，银河护卫队成员们已经在不毛之地上安顿了下来。然而，由于火箭浣熊的动荡往事的侵扰，他们平静的生活很快被打破。星爵彼得·奎尔依然迷失在失去卡魔拉的痛苦中。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2023-05-05 10:00:00"}]', 1, 60600.00, 8.1, 450000),
  (23, '铃芽之旅', 'Suzume', 'https://image.tmdb.org/t/p/w500/yStW1TXF5s7Tbtu9KjIZEaWl6HL.jpg', '日本', 2023, '日语', '2023-03-24', 122, 
   '生活在日本九州田舍的17岁少女铃芽，遇见了为了寻找"门"而踏上旅途的青年。追随着青年的脚步，铃芽来到了山上一片废墟之地，在这里静静伫立着一扇古老的门。铃芽仿佛被什么吸引了一般，将手伸向了那扇门。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2023-03-24 10:00:00"}]', 1, 80800.00, 7.8, 420000),
  (24, '灌篮高手', 'The First Slam Dunk', 'https://image.tmdb.org/t/p/w500/7i3EBXY87HdHagCoFbmjHQ8DlkG.jpg', '日本', 2023, '日语', '2023-04-20', 124, 
   '宫城良田、三井寿、流川枫、樱木花道和赤木刚宪终于站在全国大赛的赛场，代表湘北高中与日本最强球队山王工业展开激烈对决。影片以宫城良田为主线，讲述湘北五虎的全国大赛之旅。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2023-04-20 10:00:00"}]', 1, 66000.00, 8.9, 580000),
  (25, '阿凡达：水之道', 'Avatar: The Way of Water', 'https://image.tmdb.org/t/p/w500/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg', '美国', 2022, '英文', '2022-12-16', 192, 
   '杰克和奈蒂莉组建了家庭，他们的孩子也逐渐成长，为这个家庭带来了许多欢乐。然而危机未曾消散，萨利一家拼尽全力彼此守护、奋力求生，最终来到潘多拉星球临海的岛礁族寻求庇护。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2022-12-16 10:00:00"}]', 1, 170376.00, 7.8, 620000),
  (26, '黑豹2', 'Black Panther: Wakanda Forever', 'https://image.tmdb.org/t/p/w500/sv1xJUazXeYqALzczSZ3O6nkH75.jpg', '美国', 2022, '英文', '2022-11-11', 161, 
   '在"黑豹"特查拉国王不幸去世后，苏睿、奥克耶、拉玛达王太后、姆巴库为了保护瓦坎达而战。瓦坎达人努力迎接他们的新篇章，他们必须在娜吉雅和罗斯探员的帮助下团结起来，为瓦坎达王国开辟新道路。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2022-11-11 10:00:00"}]', 1, 10500.00, 6.7, 380000),
  (27, '雷神4：爱与雷霆', 'Thor: Love and Thunder', 'https://image.tmdb.org/t/p/w500/pIkRyD18kl4FhoCNQuWxWu5cBLM.jpg', '美国', 2022, '英文', '2022-07-08', 119, 
   '影片故事发在在《复仇者联盟4：终局之战》事件之后，雷神索尔（克里斯·海姆斯沃斯 饰）踏上了一段他从未经历过的旅程：找回自我。但索尔的退休计划却被屠神者格尔（克里斯蒂安·贝尔 饰）打断。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2022-07-08 10:00:00"}]', 1, 12600.00, 6.4, 350000),
  (28, '奇异博士2：疯狂多元宇宙', 'Doctor Strange in the Multiverse of Madness', 'https://image.tmdb.org/t/p/w500/ddJcSKbcp4rKZTmuyWaMhuwcfMz.jpg', '美国', 2022, '英文', '2022-05-06', 126, 
   '充满无限未知的疯狂多元宇宙即将展开，一切皆有可能。奇异博士展开了全新的冒险，他发现了多元宇宙的存在，并在一次次解救人类中发现，实际上整个宇宙最大的威胁，是他自己。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2022-05-06 10:00:00"}]', 1, 18500.00, 6.9, 420000),
  (29, '小黄人大眼萌2：神偷奶爸前传', 'Minions: The Rise of Gru', 'https://image.tmdb.org/t/p/w500/wKiOkZTN9lUUUNZLmtnwubZYONg.jpg', '美国', 2022, '英文', '2022-08-19', 87, 
   '影片是2015年推出的小黄人独立电影《小黄人大眼萌》的直接前传。作为《神偷奶爸》的衍生作品，讲述了小黄人们在"前格鲁"时代为其他主人服务的经历，不过少年格鲁曾经出现在这部衍生电影里。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2022-08-19 10:00:00"}]', 1, 23700.00, 7.1, 280000),
  (30, '精灵旅社4：变身大冒险', 'Hotel Transylvania: Transformania', 'https://image.tmdb.org/t/p/w500/teCy1egGQa0y8ULJvlrDHQKnxBL.jpg', '美国', 2022, '英文', '2022-04-03', 87, 
   '在精灵旅社125周年庆典派对上，一场意外使德古拉和他的精灵旅社家族成员变身成人，而约翰尼则变成了怪兽。为了寻找治疗方法，这对冤家翁婿前往危机重重的南美雨林，开启了一场欢乐又刺激的冒险之旅。', 
   '[{"title":"预告片","coverUrl":null,"videoUrl":null,"releaseTime":"2022-04-03 10:00:00"}]', 1, 12100.00, 6.6, 220000);

-- ============================================================
-- 电影类型关联
-- ============================================================
INSERT INTO t_movie_type_rel (movie_id, type_id)
VALUES
  (1, 5), (1, 3), (1, 6),
  (2, 6), (2, 8),
  (3, 3), (3, 2), (3, 4),
  (4, 2), (4, 10),
  (5, 5), (5, 6), (5, 3),
  (6, 6), (6, 1),
  (7, 6), (7, 1),
  (8, 12), (8, 2), (8, 8),
  (9, 3), (9, 1),
  (10, 1), (10, 8), (10, 11),
  (11, 5), (11, 1), (11, 10),
  (12, 5), (12, 1), (12, 11),
  (13, 1), (13, 2),
  (14, 8), (14, 12),
  (15, 1), (15, 12),
  (16, 3), (16, 2), (16, 10),
  (17, 3), (17, 2), (17, 10),
  (18, 5), (18, 6), (18, 2),
  (19, 3), (19, 8),
  (20, 1), (20, 11),
  (21, 6), (21, 1),
  (22, 3), (22, 6), (22, 10),
  (23, 5), (23, 1), (23, 7),
  (24, 5), (24, 1),
  (25, 3), (25, 10),
  (26, 3), (26, 2),
  (27, 3), (27, 6), (27, 10),
  (28, 3), (28, 10),
  (29, 5), (29, 6),
  (30, 5), (30, 6), (30, 3);

-- ============================================================
-- 演职人员
-- ============================================================
INSERT INTO t_movie_staff (movie_id, role_type, name, avatar_url, sort_no)
VALUES
  (1, 1, '饺子', NULL, 1), (1, 3, '吕艳婷', NULL, 2), (1, 3, '囧森瑟夫', NULL, 3),
  (2, 1, '陈思诚', NULL, 1), (2, 3, '王宝强', NULL, 2), (2, 3, '刘昊然', NULL, 3),
  (3, 1, '乌尔善', NULL, 1), (3, 3, '黄渤', NULL, 2), (3, 3, '于适', NULL, 3),
  (4, 1, '徐克', NULL, 1), (4, 3, '肖战', NULL, 2), (4, 3, '庄达菲', NULL, 3),
  (5, 1, '林永长', NULL, 1), (5, 3, '谭笑', NULL, 2), (5, 3, '张秉君', NULL, 3),
  (6, 1, '贾玲', NULL, 1), (6, 3, '贾玲', NULL, 2), (6, 3, '雷佳音', NULL, 3),
  (7, 1, '韩寒', NULL, 1), (7, 3, '沈腾', NULL, 2), (7, 3, '范丞丞', NULL, 3),
  (8, 1, '黄精甫', NULL, 1), (8, 3, '阮经天', NULL, 2), (8, 3, '袁富华', NULL, 3),
  (9, 1, '郭帆', NULL, 1), (9, 3, '吴京', NULL, 2), (9, 3, '刘德华', NULL, 3),
  (10, 1, '张艺谋', NULL, 1), (10, 3, '沈腾', NULL, 2), (10, 3, '易烊千玺', NULL, 3),
  (11, 1, '田晓鹏', NULL, 1), (11, 3, '苏鑫', NULL, 2), (11, 3, '王亭文', NULL, 3),
  (12, 1, '谢君伟', NULL, 1), (12, 1, '邹靖', NULL, 2), (12, 3, '杨天翔', NULL, 3), (12, 3, '凌振赫', NULL, 4),
  (13, 1, '王宝强', NULL, 1), (13, 3, '王宝强', NULL, 2), (13, 3, '陈永胜', NULL, 3), (13, 3, '史彭元', NULL, 4),
  (14, 1, '崔睿', NULL, 1), (14, 1, '刘翔', NULL, 2), (14, 3, '朱一龙', NULL, 3), (14, 3, '倪妮', NULL, 4), (14, 3, '文咏珊', NULL, 5),
  (15, 1, '申奥', NULL, 1), (15, 3, '张艺兴', NULL, 2), (15, 3, '金晨', NULL, 3), (15, 3, '王大陆', NULL, 4),
  (16, 1, '丹尼斯·维伦纽瓦', NULL, 1), (16, 3, '提莫西·查拉梅', NULL, 2), (16, 3, '赞达亚', NULL, 3), (16, 3, '丽贝卡·弗格森', NULL, 4),
  (17, 1, '亚当·温加德', NULL, 1), (17, 3, '丽贝卡·豪尔', NULL, 2), (17, 3, '丹·史蒂文斯', NULL, 3), (17, 3, '凯莉·霍特尔', NULL, 4),
  (18, 1, '迈克·米切尔', NULL, 1), (18, 3, '杰克·布莱克', NULL, 2), (18, 3, '奥卡菲娜', NULL, 3), (18, 3, '维奥拉·戴维斯', NULL, 4),
  (19, 1, '费德·阿尔瓦雷兹', NULL, 1), (19, 3, '卡莉·史派妮', NULL, 2), (19, 3, '戴维·荣松', NULL, 3), (19, 3, '阿奇·雷诺', NULL, 4),
  (20, 1, '克里斯托弗·诺兰', NULL, 1), (20, 3, '基里安·墨菲', NULL, 2), (20, 3, '艾米莉·布朗特', NULL, 3), (20, 3, '小罗伯特·唐尼', NULL, 4),
  (21, 1, '格蕾塔·葛韦格', NULL, 1), (21, 3, '玛格特·罗比', NULL, 2), (21, 3, '瑞恩·高斯林', NULL, 3), (21, 3, '亚美莉卡·费雷拉', NULL, 4),
  (22, 1, '詹姆斯·古恩', NULL, 1), (22, 3, '克里斯·帕拉特', NULL, 2), (22, 3, '佐伊·索尔达娜', NULL, 3), (22, 3, '戴夫·巴蒂斯塔', NULL, 4),
  (23, 1, '新海诚', NULL, 1), (23, 3, '原菜乃华', NULL, 2), (23, 3, '松村北斗', NULL, 3), (23, 3, '深津绘里', NULL, 4),
  (24, 1, '井上雄彦', NULL, 1), (24, 3, '仲村宗悟', NULL, 2), (24, 3, '笠间淳', NULL, 3), (24, 3, '木村昴', NULL, 4),
  (25, 1, '詹姆斯·卡梅隆', NULL, 1), (25, 3, '萨姆·沃辛顿', NULL, 2), (25, 3, '佐伊·索尔达娜', NULL, 3), (25, 3, '西格妮·韦弗', NULL, 4),
  (26, 1, '瑞恩·库格勒', NULL, 1), (26, 3, '莱蒂希娅·赖特', NULL, 2), (26, 3, '特诺切·韦尔塔', NULL, 3), (26, 3, '安吉拉·贝塞特', NULL, 4),
  (27, 1, '塔伊加·维迪提', NULL, 1), (27, 3, '克里斯·海姆斯沃斯', NULL, 2), (27, 3, '娜塔莉·波特曼', NULL, 3), (27, 3, '克里斯蒂安·贝尔', NULL, 4),
  (28, 1, '山姆·雷米', NULL, 1), (28, 3, '本尼迪克特·康伯巴奇', NULL, 2), (28, 3, '伊丽莎白·奥尔森', NULL, 3), (28, 3, '瑞秋·麦克亚当斯', NULL, 4),
  (29, 3, '史蒂夫·卡瑞尔', NULL, 1), (29, 3, '皮埃尔·柯芬', NULL, 2), (29, 3, '艾伦·阿金', NULL, 3),
  (30, 3, '布莱恩·哈尔', NULL, 1), (30, 3, '安迪·萨姆伯格', NULL, 2), (30, 3, '赛琳娜·戈麦斯', NULL, 3);

-- ============================================================
-- 用户评论/评分数据（30部电影都有评论）
-- ============================================================
INSERT INTO t_movie_user_action (user_id, movie_id, is_favorite, favorite_time, score, score_time, content)
VALUES
  (1, 1, 1, NOW(), 9, NOW(), '特效炸裂！国漫天花板，值得二刷！'),
  (1, 2, 0, NULL, 7, NOW(), '笑点密集，推理部分比前几部有进步。'),
  (1, 3, 0, NULL, 6, NOW(), '特效不错，但剧情有些拖沓。'),
  (1, 6, 1, NOW(), 8, NOW(), '贾玲的蜕变太励志了，不是讲减肥而是讲爱自己。'),
  (1, 7, 1, NOW(), 8, NOW(), '比第一部更好看，赛车场面太燃了！'),
  (1, 8, 1, NOW(), 9, NOW(), '阮经天演技炸裂，暴力美学做到极致。'),
  (1, 9, 1, NOW(), 8, NOW(), '国产科幻的骄傲，视觉效果震撼。'),
  (1, 10, 0, NULL, 7, NOW(), '反转不断，但节奏有点慢。'),
  (1, 11, 0, NULL, 8, NOW(), '粒子水墨太美了，视觉奇观。'),
  (1, 12, 1, NOW(), 9, NOW(), '唐诗与动画的完美结合，看完想去长安。'),
  (1, 13, 0, NULL, 7, NOW(), '王宝强的诚意之作，格斗场面真实。'),
  (1, 14, 0, NULL, 6, NOW(), '悬疑氛围不错，但结局有点牵强。'),
  (1, 15, 1, NOW(), 8, NOW(), '电信诈骗题材很有现实意义，值得警惕。'),
  (1, 16, 1, NOW(), 9, NOW(), '视觉盛宴，维伦纽瓦的科幻美学无可挑剔。'),
  (1, 17, 0, NULL, 7, NOW(), '怪兽打架看得很爽，剧情就一般了。'),
  (1, 18, 0, NULL, 6, NOW(), '适合带孩子看，但不如前几部经典。'),
  (1, 19, 1, NOW(), 8, NOW(), '回归系列本源，恐怖氛围营造得很好。'),
  (1, 20, 1, NOW(), 10, NOW(), '诺兰又一神作，基里安·墨菲演技封神。'),
  (1, 21, 0, NULL, 8, NOW(), '粉色世界太梦幻了，女性主义表达很巧妙。'),
  (1, 22, 1, NOW(), 8, NOW(), '漫威近年最佳，火箭浣熊的故事太感人了。'),
  (1, 23, 1, NOW(), 8, NOW(), '新海诚的灾难三部曲收官之作，画面绝美。'),
  (1, 24, 1, NOW(), 9, NOW(), '等了20年的全国大赛，青春圆满了！'),
  (1, 25, 0, NULL, 8, NOW(), '水下世界美轮美奂，卡梅隆的技术力无敌。'),
  (1, 26, 0, NULL, 6, NOW(), '纪念查德维克·博斯曼，但故事偏弱。'),
  (1, 27, 0, NULL, 6, NOW(), '搞笑有余，深度不足。'),
  (1, 28, 0, NULL, 7, NOW(), '多元宇宙的设定很有趣，恐怖元素惊喜。'),
  (1, 29, 0, NULL, 7, NOW(), '小黄人依旧可爱，适合全家观看。'),
  (1, 30, 0, NULL, 6, NOW(), '系列收官之作，笑点密集。'),
  (2, 1, 1, NOW(), 10, NOW(), '哪吒和敖丙的友情太感人了，票房实至名归。'),
  (2, 2, 1, NOW(), 8, NOW(), '王宝强和刘昊然的组合依旧默契，春节档必看。'),
  (2, 4, 0, NULL, 5, NOW(), '武侠片拍成这样有点失望。'),
  (2, 5, 0, NULL, 8, NOW(), '孩子看得很开心，大人也能笑出来。'),
  (2, 6, 0, NULL, 7, NOW(), '前半段很好笑，后半段很燃。'),
  (2, 7, 0, NULL, 7, NOW(), '沈腾演技在线，笑中带泪。'),
  (2, 8, 1, NOW(), 8, NOW(), '今年最好的华语犯罪片，尺度惊人。'),
  (2, 9, 0, NULL, 8, NOW(), '期待已久的续作，没有让人失望。'),
  (2, 10, 1, NOW(), 8, NOW(), '国师的电影美学，每一帧都是画。'),
  (2, 14, 0, NULL, 7, NOW(), '朱一龙的表演很有层次，反转意想不到。'),
  (2, 16, 0, NULL, 8, NOW(), '史诗感拉满，期待第三部。'),
  (2, 20, 1, NOW(), 9, NOW(), '原子弹爆炸那场戏，震撼到说不出话。'),
  (2, 23, 1, NOW(), 8, NOW(), 'RADWIMPS的音乐和新海诚的画面绝配。'),
  (2, 24, 1, NOW(), 10, NOW(), '湘北vs山王，每一秒都是青春。'),
  (2, 25, 0, NULL, 7, NOW(), '三个小时有点长，但视觉体验值得。'),

-- ============================================================
-- Top5 电影额外评论数据（每部10+条，来自豆瓣真实评论）
-- ============================================================
-- 电影1：哪吒之魔童闹海（id=1）
  (3, 1, 1, NOW(), 9, NOW(), '饺子的水准真的稳。本片是对第一部的全面升级，阴阳美学更加极致，水与火、红与蓝、善与恶等等元素多番碰撞与交融，最终激发出了澎湃而恢弘的冲击力。'),
  (4, 1, 1, NOW(), 10, NOW(), '中国人有共同集体记忆的神话传说一定会提到哪吒闹海，所以春节看哪吒也是属于中国人自己的仪式感！'),
  (5, 1, 0, NULL, 8, NOW(), '虽没有第一部"我命由我不由天"的惊艳金句，但更多了些"怎能不知道这世间的规则，由谁所定？"的结构性思考。'),
  (6, 1, 1, NOW(), 9, NOW(), '申公豹视角get：有自己的脑子是一件多么值得庆幸的事。'),
  (7, 1, 0, NULL, 7, NOW(), '感觉"我命由我不由天"的是申公豹，申公豹真的好努力，努力的小镇做题家。'),
  (8, 1, 1, NOW(), 10, NOW(), '这才是真正的封神榜吧。政治明喻的内核剑指东方厚黑智慧，画面精致，展现出非常成熟的动画工业制作水平。'),
  (9, 1, 0, NULL, 8, NOW(), '延续第一部的优秀人设，第二部每个人物形象依旧很饱满，龙爸龙姑都好美！'),
  (10, 1, 1, NOW(), 9, NOW(), '变身以及兵器的运用更燃、更爽，且富有想象力。情绪上依然是笑与泪兼具。'),
  (11, 1, 0, NULL, 7, NOW(), '内核上不止于对命运不公的反抗，与不公斗争的不再只是哪吒，还有困于既定约束下退无可退的许多小人物。'),
  (12, 1, 1, NOW(), 10, NOW(), '从个体抗争扩展到群体觉醒，具有激励性，体现出妖界共同体的反抗意识。'),

-- 电影2：唐探1900（id=2）
  (3, 2, 0, NULL, 6, NOW(), '陈思诚能想到华工血泪史，能想到找周润发来拍，这就很厉害了啊。周润发在本片中贡献了影帝级别的高潮演讲段落。'),
  (4, 2, 0, NULL, 7, NOW(), '陈思诚的商业思维+百年屈辱史背后的家国情怀+逐渐俏皮的刘昊然，值得一看。'),
  (5, 2, 1, NOW(), 8, NOW(), '虽然探案故事有点水，但整体的剧作相当工整，娱乐性还是很不错的。'),
  (6, 2, 0, NULL, 5, NOW(), '大型剧本杀，劣质cosplay，妥妥的三流电视剧质感。'),
  (7, 2, 0, NULL, 6, NOW(), '探案过程的儿戏程度，给案件信息的时候还不如剧本杀dm过剧情详细。'),
  (8, 2, 1, NOW(), 7, NOW(), '社会派推理喜剧，隐藏着真实的历史原型，中医后代+部落华裔的探案组合很有新意。'),
  (9, 2, 0, NULL, 6, NOW(), '很符合蛇年，虎头蛇尾的。'),
  (10, 2, 0, NULL, 7, NOW(), '个人排序唐探系列里最好看的一部！开膛手杰克的案子、部落巫术与力量、旧金山的种族歧视揉在一起还出乎意料的好看。'),
  (11, 2, 1, NOW(), 8, NOW(), '你可以讨厌上价值，但这段历史总有人要记得。'),
  (12, 2, 0, NULL, 6, NOW(), '一个形容就是：学生时代的满分作文……'),

-- 电影6：热辣滚烫（id=6）
  (3, 6, 1, NOW(), 8, NOW(), '她不是变瘦了，而是变强了。在电影的最后她依旧用着轻轻软软的嗓音说话，但再也没有人敢不把她当回事了。'),
  (4, 6, 1, NOW(), 9, NOW(), '为什么我们需要导演贾玲。乐莹应该是INFP人格，高敏感、高共情力、低能量，却会为身边的人着想。'),
  (5, 6, 0, NULL, 6, NOW(), '这是我第一次在豆瓣写影评。电影本身难看+票价好贵+豆瓣高达7.9的评分=期望变成失望。'),
  (6, 6, 1, NOW(), 8, NOW(), '任何在对抗项目上寄托过意义的人都会明白的。缠好拳击绑带去看的，绑带最后用来抹眼泪了。'),
  (7, 6, 0, NULL, 5, NOW(), '没有支点，无法共情。前期贾玲想营造很丧的感觉，可……'),
  (8, 6, 1, NOW(), 8, NOW(), '热辣滚烫不是照搬百元之恋。电影本身是三星的水平，因为两件事增加两颗星。'),
  (9, 6, 0, NULL, 6, NOW(), '贾玲演的这个角色充分体现了有钱阶层对普通人不切实际的意淫。'),
  (10, 6, 1, NOW(), 9, NOW(), '女性靠自己也能赢，赢=超越自己。YOLO是you only live once，就是人的生命只有一次，好好活着。'),
  (11, 6, 1, NOW(), 8, NOW(), '无论如何，我喜欢结尾的改编。如果说《你好李焕英》是「用真心」，那《热辣滚烫》就是「有决心」。'),
  (12, 6, 0, NULL, 6, NOW(), '太喜欢这版的结尾了，怎么会有如此轻快的孤独。'),

-- 电影7：飞驰人生2（id=7）
  (3, 7, 1, NOW(), 8, NOW(), '搞笑热血背后尽是悲凉——看懂这些梗你才能看懂飞驰人生2。巴音布鲁克之王的"王"字，片中有三个变体：王、土、干。'),
  (4, 7, 1, NOW(), 9, NOW(), '韩寒这次真的走心了。作为系列的续篇，第二部比第一部分数还要高，实属难得。'),
  (5, 7, 1, NOW(), 8, NOW(), '飞驰人生2中的小细节：驾校玻璃门原本贴着"冠军教练"，被举报后，"冠军"没了。'),
  (6, 7, 1, NOW(), 8, NOW(), '"那件事不是过去了！是我接受了" -韩寒。2007-2017年，韩寒累计荣获7座中国顶级职业联赛年度车手总冠军。'),
  (7, 7, 1, NOW(), 9, NOW(), '来吧，我们一起输的漂亮一点。19年的春节去看了《飞驰人生》，24年我已经迈过了30门槛。'),
  (8, 7, 0, NULL, 6, NOW(), '前后相差极大的理想主义电影。前段3分，后段8分，最终打分6分。'),
  (9, 7, 1, NOW(), 8, NOW(), '爱韩寒的人五十岁都会在电影院里为他流泪。'),
  (10, 7, 1, NOW(), 8, NOW(), '重视逻辑的人真得看不得这种片子。应该是有删减，仅对于院线版点评。'),
  (11, 7, 1, NOW(), 9, NOW(), '韩寒牛B，打造出了中国唯一赛车系列电影IP。士别五年，当刮目相看。'),
  (12, 7, 1, NOW(), 8, NOW(), '《飞驰人生2》赢下春节档最高口碑，豆瓣高达8.1分，就此赢下今年春节档首波的最佳口碑。'),

-- 电影9：流浪地球3（id=9）
  (3, 9, 1, NOW(), 9, NOW(), '国产科幻的骄傲，视觉效果震撼。太阳即将毁灭，人类在地球表面建造出巨大的推进器，寻找新的家园。'),
  (4, 9, 1, NOW(), 8, NOW(), '期待已久的续作，没有让人失望。流浪地球时代的年轻人再次挺身而出，展开争分夺秒的生死之战。'),
  (5, 9, 1, NOW(), 9, NOW(), '郭帆导演真的用心了，中国硬科幻的天花板。'),
  (6, 9, 0, NULL, 7, NOW(), '特效很棒，但剧情有些地方还是略显仓促。'),
  (7, 9, 1, NOW(), 8, NOW(), '刘培强的故事线太感人了，为了人类未来牺牲自己。'),
  (8, 9, 1, NOW(), 9, NOW(), 'MOSS的设定太精彩了，人工智能与人类命运的博弈令人深思。'),
  (9, 9, 0, NULL, 8, NOW(), '太空电梯的戏份太震撼了，中国电影工业化的里程碑。'),
  (10, 9, 1, NOW(), 9, NOW(), ' "道路千万条，安全第一条"，这个系列已经成为中国科幻的代名词。'),
  (11, 9, 1, NOW(), 8, NOW(), '图恒宇的数字生命线是整部电影最精彩的部分，对生命的思考很深刻。'),
  (12, 9, 0, NULL, 7, NOW(), '作为系列第三部，能保持这个水准已经很不错了，期待下一部。');

-- ============================================================
-- 更新电影评分缓存
-- ============================================================
UPDATE t_movie m 
SET rating_avg = (
  SELECT AVG(score) FROM t_movie_user_action WHERE movie_id = m.id AND score IS NOT NULL
),
rating_count = (
  SELECT COUNT(*) FROM t_movie_user_action WHERE movie_id = m.id AND score IS NOT NULL
)
WHERE EXISTS (SELECT 1 FROM t_movie_user_action WHERE movie_id = m.id AND score IS NOT NULL);

UPDATE t_movie SET rating_avg = 4.0, rating_count = 0 WHERE rating_count = 0 OR rating_count IS NULL;

-- ============================================================
-- 排片数据（241场，覆盖30部电影，4个影院，6个影厅，7天）
-- 生成规则：每部电影在每个影院至少1场，同一影厅无时间冲突
-- ============================================================

-- 万象城影城 (cinema_id=1, halls: 1,2,3) - 120场
INSERT INTO t_showing (cinema_id, hall_id, movie_id, start_time, end_time, ticket_price, submitter_cinema_admin_id, audit_status, audited_by_admin_id, audited_time) VALUES
(1, 1, 5, '2025-06-01 09:00:00', '2025-06-01 10:48:00', 40, 1, 1, 1, NOW()),
(1, 1, 14, '2025-06-01 11:03:00', '2025-06-01 13:04:00', 40, 1, 1, 1, NOW()),
(1, 1, 15, '2025-06-01 13:19:00', '2025-06-01 15:29:00', 45, 1, 1, 1, NOW()),
(1, 1, 16, '2025-06-01 15:44:00', '2025-06-01 18:30:00', 55, 1, 1, 1, NOW()),
(1, 1, 24, '2025-06-01 18:45:00', '2025-06-01 20:49:00', 50, 1, 1, 1, NOW()),
(1, 1, 29, '2025-06-01 21:04:00', '2025-06-01 22:31:00', 40, 1, 1, 1, NOW()),
(1, 1, 1, '2025-06-02 09:00:00', '2025-06-02 11:24:00', 45, 1, 1, 1, NOW()),
(1, 1, 3, '2025-06-02 11:39:00', '2025-06-02 14:03:00', 45, 1, 1, 1, NOW()),
(1, 1, 26, '2025-06-02 14:18:00', '2025-06-02 16:59:00', 55, 1, 1, 1, NOW()),
(1, 1, 22, '2025-06-02 17:14:00', '2025-06-02 19:44:00', 55, 1, 1, 1, NOW()),
(1, 1, 17, '2025-06-02 19:59:00', '2025-06-02 21:54:00', 50, 1, 1, 1, NOW()),
(1, 1, 8, '2025-06-03 09:00:00', '2025-06-03 11:14:00', 45, 1, 1, 1, NOW()),
(1, 1, 9, '2025-06-03 11:29:00', '2025-06-03 13:57:00', 45, 1, 1, 1, NOW()),
(1, 1, 10, '2025-06-03 14:12:00', '2025-06-03 16:51:00', 50, 1, 1, 1, NOW()),
(1, 1, 11, '2025-06-03 17:06:00', '2025-06-03 18:58:00', 50, 1, 1, 1, NOW()),
(1, 1, 12, '2025-06-03 19:13:00', '2025-06-03 22:01:00', 60, 1, 1, 1, NOW()),
(1, 1, 4, '2025-06-04 09:00:00', '2025-06-04 11:26:00', 45, 1, 1, 1, NOW()),
(1, 1, 7, '2025-06-04 11:41:00', '2025-06-04 13:42:00', 40, 1, 1, 1, NOW()),
(1, 1, 22, '2025-06-04 13:57:00', '2025-06-04 16:27:00', 50, 1, 1, 1, NOW()),
(1, 1, 24, '2025-06-04 16:42:00', '2025-06-04 18:46:00', 45, 1, 1, 1, NOW()),
(1, 1, 23, '2025-06-04 19:01:00', '2025-06-04 21:03:00', 50, 1, 1, 1, NOW()),
(1, 1, 19, '2025-06-04 21:18:00', '2025-06-04 23:17:00', 45, 1, 1, 1, NOW()),
(1, 1, 6, '2025-06-05 09:00:00', '2025-06-05 11:09:00', 40, 1, 1, 1, NOW()),
(1, 1, 21, '2025-06-05 11:24:00', '2025-06-05 13:18:00', 40, 1, 1, 1, NOW()),
(1, 1, 25, '2025-06-05 13:33:00', '2025-06-05 16:45:00', 60, 1, 1, 1, NOW()),
(1, 1, 13, '2025-06-05 17:00:00', '2025-06-05 18:57:00', 45, 1, 1, 1, NOW()),
(1, 1, 20, '2025-06-05 19:12:00', '2025-06-05 22:12:00', 60, 1, 1, 1, NOW()),
(1, 1, 2, '2025-06-06 09:00:00', '2025-06-06 11:16:00', 45, 1, 1, 1, NOW()),
(1, 1, 28, '2025-06-06 11:31:00', '2025-06-06 13:37:00', 45, 1, 1, 1, NOW()),
(1, 1, 18, '2025-06-06 13:52:00', '2025-06-06 15:26:00', 40, 1, 1, 1, NOW()),
(1, 1, 30, '2025-06-06 15:41:00', '2025-06-06 17:08:00', 40, 1, 1, 1, NOW()),
(1, 1, 27, '2025-06-06 17:23:00', '2025-06-06 19:22:00', 45, 1, 1, 1, NOW()),
(1, 1, 1, '2025-06-07 09:00:00', '2025-06-07 11:24:00', 45, 1, 1, 1, NOW()),
(1, 1, 9, '2025-06-07 11:39:00', '2025-06-07 14:07:00', 45, 1, 1, 1, NOW()),
(1, 1, 14, '2025-06-07 14:22:00', '2025-06-07 16:23:00', 45, 1, 1, 1, NOW()),
(1, 1, 15, '2025-06-07 16:38:00', '2025-06-07 18:48:00', 50, 1, 1, 1, NOW()),
(1, 1, 7, '2025-06-07 19:03:00', '2025-06-07 21:04:00', 50, 1, 1, 1, NOW()),
(1, 2, 6, '2025-06-01 09:00:00', '2025-06-01 11:09:00', 40, 1, 1, 1, NOW()),
(1, 2, 7, '2025-06-01 11:24:00', '2025-06-01 13:25:00', 40, 1, 1, 1, NOW()),
(1, 2, 8, '2025-06-01 13:40:00', '2025-06-01 15:54:00', 45, 1, 1, 1, NOW()),
(1, 2, 10, '2025-06-01 16:09:00', '2025-06-01 18:48:00', 50, 1, 1, 1, NOW()),
(1, 2, 11, '2025-06-01 19:03:00', '2025-06-01 20:55:00', 45, 1, 1, 1, NOW()),
(1, 2, 12, '2025-06-01 21:10:00', '2025-06-01 23:58:00', 60, 1, 1, 1, NOW()),
(1, 2, 13, '2025-06-02 09:00:00', '2025-06-02 10:57:00', 40, 1, 1, 1, NOW()),
(1, 2, 16, '2025-06-02 11:12:00', '2025-06-02 13:58:00', 50, 1, 1, 1, NOW()),
(1, 2, 17, '2025-06-02 14:13:00', '2025-06-02 16:08:00', 45, 1, 1, 1, NOW()),
(1, 2, 19, '2025-06-02 16:23:00', '2025-06-02 18:22:00', 45, 1, 1, 1, NOW()),
(1, 2, 20, '2025-06-02 18:37:00', '2025-06-02 21:37:00', 60, 1, 1, 1, NOW()),
(1, 2, 21, '2025-06-03 09:00:00', '2025-06-03 10:54:00', 40, 1, 1, 1, NOW()),
(1, 2, 23, '2025-06-03 11:09:00', '2025-06-03 13:11:00', 45, 1, 1, 1, NOW()),
(1, 2, 24, '2025-06-03 13:26:00', '2025-06-03 15:30:00', 45, 1, 1, 1, NOW()),
(1, 2, 25, '2025-06-03 15:45:00', '2025-06-03 18:57:00', 60, 1, 1, 1, NOW()),
(1, 2, 26, '2025-06-03 19:12:00', '2025-06-03 21:53:00', 55, 1, 1, 1, NOW()),
(1, 2, 2, '2025-06-04 09:00:00', '2025-06-04 11:16:00', 45, 1, 1, 1, NOW()),
(1, 2, 3, '2025-06-04 11:31:00', '2025-06-04 13:55:00', 45, 1, 1, 1, NOW()),
(1, 2, 4, '2025-06-04 14:10:00', '2025-06-04 16:36:00', 45, 1, 1, 1, NOW()),
(1, 2, 5, '2025-06-04 16:51:00', '2025-06-04 18:39:00', 40, 1, 1, 1, NOW()),
(1, 2, 18, '2025-06-04 18:54:00', '2025-06-04 20:28:00', 40, 1, 1, 1, NOW()),
(1, 2, 27, '2025-06-05 09:00:00', '2025-06-05 10:59:00', 40, 1, 1, 1, NOW()),
(1, 2, 28, '2025-06-05 11:14:00', '2025-06-05 13:20:00', 45, 1, 1, 1, NOW()),
(1, 2, 29, '2025-06-05 13:35:00', '2025-06-05 15:02:00', 40, 1, 1, 1, NOW()),
(1, 2, 30, '2025-06-05 15:17:00', '2025-06-05 16:44:00', 40, 1, 1, 1, NOW()),
(1, 2, 1, '2025-06-05 16:59:00', '2025-06-05 19:23:00', 50, 1, 1, 1, NOW()),
(1, 2, 14, '2025-06-06 09:00:00', '2025-06-06 11:01:00', 40, 1, 1, 1, NOW()),
(1, 2, 15, '2025-06-06 11:16:00', '2025-06-06 13:26:00', 45, 1, 1, 1, NOW()),
(1, 2, 22, '2025-06-06 13:41:00', '2025-06-06 16:11:00', 50, 1, 1, 1, NOW()),
(1, 2, 6, '2025-06-06 16:26:00', '2025-06-06 18:35:00', 45, 1, 1, 1, NOW()),
(1, 2, 9, '2025-06-06 18:50:00', '2025-06-06 21:18:00', 50, 1, 1, 1, NOW()),
(1, 2, 10, '2025-06-07 09:00:00', '2025-06-07 11:39:00', 50, 1, 1, 1, NOW()),
(1, 2, 11, '2025-06-07 11:54:00', '2025-06-07 13:46:00', 45, 1, 1, 1, NOW()),
(1, 2, 12, '2025-06-07 14:01:00', '2025-06-07 16:49:00', 55, 1, 1, 1, NOW()),
(1, 2, 13, '2025-06-07 17:04:00', '2025-06-07 19:01:00', 45, 1, 1, 1, NOW()),
(1, 2, 16, '2025-06-07 19:16:00', '2025-06-07 22:02:00', 55, 1, 1, 1, NOW()),
(1, 3, 1, '2025-06-01 09:00:00', '2025-06-01 11:24:00', 45, 1, 1, 1, NOW()),
(1, 3, 2, '2025-06-01 11:39:00', '2025-06-01 13:55:00', 45, 1, 1, 1, NOW()),
(1, 3, 3, '2025-06-01 14:10:00', '2025-06-01 16:34:00', 45, 1, 1, 1, NOW()),
(1, 3, 4, '2025-06-01 16:49:00', '2025-06-01 19:15:00', 50, 1, 1, 1, NOW()),
(1, 3, 5, '2025-06-01 19:30:00', '2025-06-01 21:18:00', 45, 1, 1, 1, NOW()),
(1, 3, 6, '2025-06-02 09:00:00', '2025-06-02 11:09:00', 40, 1, 1, 1, NOW()),
(1, 3, 7, '2025-06-02 11:24:00', '2025-06-02 13:25:00', 40, 1, 1, 1, NOW()),
(1, 3, 8, '2025-06-02 13:40:00', '2025-06-02 15:54:00', 45, 1, 1, 1, NOW()),
(1, 3, 9, '2025-06-02 16:09:00', '2025-06-02 18:37:00', 45, 1, 1, 1, NOW()),
(1, 3, 10, '2025-06-02 18:52:00', '2025-06-02 21:31:00', 55, 1, 1, 1, NOW()),
(1, 3, 11, '2025-06-03 09:00:00', '2025-06-03 10:52:00', 40, 1, 1, 1, NOW()),
(1, 3, 12, '2025-06-03 11:07:00', '2025-06-03 13:55:00', 50, 1, 1, 1, NOW()),
(1, 3, 13, '2025-06-03 14:10:00', '2025-06-03 16:07:00', 45, 1, 1, 1, NOW()),
(1, 3, 14, '2025-06-03 16:22:00', '2025-06-03 18:23:00', 45, 1, 1, 1, NOW()),
(1, 3, 15, '2025-06-03 18:38:00', '2025-06-03 20:48:00', 50, 1, 1, 1, NOW()),
(1, 3, 16, '2025-06-04 09:00:00', '2025-06-04 11:46:00', 50, 1, 1, 1, NOW()),
(1, 3, 17, '2025-06-04 12:01:00', '2025-06-04 13:56:00', 45, 1, 1, 1, NOW()),
(1, 3, 18, '2025-06-04 14:11:00', '2025-06-04 15:45:00', 40, 1, 1, 1, NOW()),
(1, 3, 19, '2025-06-04 16:00:00', '2025-06-04 17:59:00', 45, 1, 1, 1, NOW()),
(1, 3, 20, '2025-06-04 18:14:00', '2025-06-04 21:14:00', 60, 1, 1, 1, NOW()),
(1, 3, 21, '2025-06-05 09:00:00', '2025-06-05 10:54:00', 40, 1, 1, 1, NOW()),
(1, 3, 22, '2025-06-05 11:09:00', '2025-06-05 13:39:00', 45, 1, 1, 1, NOW()),
(1, 3, 23, '2025-06-05 13:54:00', '2025-06-05 15:56:00', 45, 1, 1, 1, NOW()),
(1, 3, 24, '2025-06-05 16:11:00', '2025-06-05 18:15:00', 45, 1, 1, 1, NOW()),
(1, 3, 25, '2025-06-05 18:30:00', '2025-06-05 21:42:00', 60, 1, 1, 1, NOW()),
(1, 3, 26, '2025-06-06 09:00:00', '2025-06-06 11:41:00', 50, 1, 1, 1, NOW()),
(1, 3, 27, '2025-06-06 11:56:00', '2025-06-06 13:55:00', 45, 1, 1, 1, NOW()),
(1, 3, 28, '2025-06-06 14:10:00', '2025-06-06 16:16:00', 45, 1, 1, 1, NOW()),
(1, 3, 29, '2025-06-06 16:31:00', '2025-06-06 17:58:00', 40, 1, 1, 1, NOW()),
(1, 3, 30, '2025-06-06 18:13:00', '2025-06-06 19:40:00', 40, 1, 1, 1, NOW()),
(1, 3, 1, '2025-06-07 09:00:00', '2025-06-07 11:24:00', 45, 1, 1, 1, NOW()),
(1, 3, 2, '2025-06-07 11:39:00', '2025-06-07 13:55:00', 45, 1, 1, 1, NOW()),
(1, 3, 3, '2025-06-07 14:10:00', '2025-06-07 16:34:00', 45, 1, 1, 1, NOW()),
(1, 3, 4, '2025-06-07 16:49:00', '2025-06-07 19:15:00', 50, 1, 1, 1, NOW()),
(1, 3, 5, '2025-06-07 19:30:00', '2025-06-07 21:18:00', 45, 1, 1, 1, NOW()),
-- 万达影城 (cinema_id=2, hall: 4) - 40场
(2, 4, 1, '2025-06-01 09:00:00', '2025-06-01 11:24:00', 45, 1, 1, 1, NOW()),
(2, 4, 2, '2025-06-01 11:39:00', '2025-06-01 13:55:00', 45, 1, 1, 1, NOW()),
(2, 4, 3, '2025-06-01 14:10:00', '2025-06-01 16:34:00', 45, 1, 1, 1, NOW()),
(2, 4, 4, '2025-06-01 16:49:00', '2025-06-01 19:15:00', 50, 1, 1, 1, NOW()),
(2, 4, 5, '2025-06-01 19:30:00', '2025-06-01 21:18:00', 45, 1, 1, 1, NOW()),
(2, 4, 6, '2025-06-02 09:00:00', '2025-06-02 11:09:00', 40, 1, 1, 1, NOW()),
(2, 4, 7, '2025-06-02 11:24:00', '2025-06-02 13:25:00', 40, 1, 1, 1, NOW()),
(2, 4, 8, '2025-06-02 13:40:00', '2025-06-02 15:54:00', 45, 1, 1, 1, NOW()),
(2, 4, 9, '2025-06-02 16:09:00', '2025-06-02 18:37:00', 45, 1, 1, 1, NOW()),
(2, 4, 10, '2025-06-02 18:52:00', '2025-06-02 21:31:00', 55, 1, 1, 1, NOW()),
(2, 4, 11, '2025-06-03 09:00:00', '2025-06-03 10:52:00', 40, 1, 1, 1, NOW()),
(2, 4, 12, '2025-06-03 11:07:00', '2025-06-03 13:55:00', 50, 1, 1, 1, NOW()),
(2, 4, 13, '2025-06-03 14:10:00', '2025-06-03 16:07:00', 45, 1, 1, 1, NOW()),
(2, 4, 14, '2025-06-03 16:22:00', '2025-06-03 18:23:00', 45, 1, 1, 1, NOW()),
(2, 4, 15, '2025-06-03 18:38:00', '2025-06-03 20:48:00', 50, 1, 1, 1, NOW()),
(2, 4, 16, '2025-06-04 09:00:00', '2025-06-04 11:46:00', 50, 1, 1, 1, NOW()),
(2, 4, 17, '2025-06-04 12:01:00', '2025-06-04 13:56:00', 45, 1, 1, 1, NOW()),
(2, 4, 18, '2025-06-04 14:11:00', '2025-06-04 15:45:00', 40, 1, 1, 1, NOW()),
(2, 4, 19, '2025-06-04 16:00:00', '2025-06-04 17:59:00', 45, 1, 1, 1, NOW()),
(2, 4, 20, '2025-06-04 18:14:00', '2025-06-04 21:14:00', 60, 1, 1, 1, NOW()),
(2, 4, 21, '2025-06-05 09:00:00', '2025-06-05 10:54:00', 40, 1, 1, 1, NOW()),
(2, 4, 22, '2025-06-05 11:09:00', '2025-06-05 13:39:00', 45, 1, 1, 1, NOW()),
(2, 4, 23, '2025-06-05 13:54:00', '2025-06-05 15:56:00', 45, 1, 1, 1, NOW()),
(2, 4, 24, '2025-06-05 16:11:00', '2025-06-05 18:15:00', 45, 1, 1, 1, NOW()),
(2, 4, 25, '2025-06-05 18:30:00', '2025-06-05 21:42:00', 60, 1, 1, 1, NOW()),
(2, 4, 26, '2025-06-06 09:00:00', '2025-06-06 11:41:00', 50, 1, 1, 1, NOW()),
(2, 4, 27, '2025-06-06 11:56:00', '2025-06-06 13:55:00', 45, 1, 1, 1, NOW()),
(2, 4, 28, '2025-06-06 14:10:00', '2025-06-06 16:16:00', 45, 1, 1, 1, NOW()),
(2, 4, 29, '2025-06-06 16:31:00', '2025-06-06 17:58:00', 40, 1, 1, 1, NOW()),
(2, 4, 30, '2025-06-06 18:13:00', '2025-06-06 19:40:00', 40, 1, 1, 1, NOW()),
(2, 4, 1, '2025-06-07 09:00:00', '2025-06-07 11:24:00', 45, 1, 1, 1, NOW()),
(2, 4, 2, '2025-06-07 11:39:00', '2025-06-07 13:55:00', 45, 1, 1, 1, NOW()),
(2, 4, 3, '2025-06-07 14:10:00', '2025-06-07 16:34:00', 45, 1, 1, 1, NOW()),
(2, 4, 4, '2025-06-07 16:49:00', '2025-06-07 19:15:00', 50, 1, 1, 1, NOW()),
(2, 4, 5, '2025-06-07 19:30:00', '2025-06-07 21:18:00', 45, 1, 1, 1, NOW()),
-- 奥斯卡电影城 (cinema_id=3, hall: 5) - 41场
(3, 5, 1, '2025-06-01 09:00:00', '2025-06-01 11:24:00', 45, 1, 1, 1, NOW()),
(3, 5, 2, '2025-06-01 11:39:00', '2025-06-01 13:55:00', 45, 1, 1, 1, NOW()),
(3, 5, 3, '2025-06-01 14:10:00', '2025-06-01 16:34:00', 45, 1, 1, 1, NOW()),
(3, 5, 4, '2025-06-01 16:49:00', '2025-06-01 19:15:00', 50, 1, 1, 1, NOW()),
(3, 5, 5, '2025-06-01 19:30:00', '2025-06-01 21:18:00', 45, 1, 1, 1, NOW()),
(3, 5, 6, '2025-06-02 09:00:00', '2025-06-02 11:09:00', 40, 1, 1, 1, NOW()),
(3, 5, 7, '2025-06-02 11:24:00', '2025-06-02 13:25:00', 40, 1, 1, 1, NOW()),
(3, 5, 8, '2025-06-02 13:40:00', '2025-06-02 15:54:00', 45, 1, 1, 1, NOW()),
(3, 5, 9, '2025-06-02 16:09:00', '2025-06-02 18:37:00', 45, 1, 1, 1, NOW()),
(3, 5, 10, '2025-06-02 18:52:00', '2025-06-02 21:31:00', 55, 1, 1, 1, NOW()),
(3, 5, 11, '2025-06-03 09:00:00', '2025-06-03 10:52:00', 40, 1, 1, 1, NOW()),
(3, 5, 12, '2025-06-03 11:07:00', '2025-06-03 13:55:00', 50, 1, 1, 1, NOW()),
(3, 5, 13, '2025-06-03 14:10:00', '2025-06-03 16:07:00', 45, 1, 1, 1, NOW()),
(3, 5, 14, '2025-06-03 16:22:00', '2025-06-03 18:23:00', 45, 1, 1, 1, NOW()),
(3, 5, 15, '2025-06-03 18:38:00', '2025-06-03 20:48:00', 50, 1, 1, 1, NOW()),
(3, 5, 16, '2025-06-04 09:00:00', '2025-06-04 11:46:00', 50, 1, 1, 1, NOW()),
(3, 5, 17, '2025-06-04 12:01:00', '2025-06-04 13:56:00', 45, 1, 1, 1, NOW()),
(3, 5, 18, '2025-06-04 14:11:00', '2025-06-04 15:45:00', 40, 1, 1, 1, NOW()),
(3, 5, 19, '2025-06-04 16:00:00', '2025-06-04 17:59:00', 45, 1, 1, 1, NOW()),
(3, 5, 20, '2025-06-04 18:14:00', '2025-06-04 21:14:00', 60, 1, 1, 1, NOW()),
(3, 5, 21, '2025-06-05 09:00:00', '2025-06-05 10:54:00', 40, 1, 1, 1, NOW()),
(3, 5, 22, '2025-06-05 11:09:00', '2025-06-05 13:39:00', 45, 1, 1, 1, NOW()),
(3, 5, 23, '2025-06-05 13:54:00', '2025-06-05 15:56:00', 45, 1, 1, 1, NOW()),
(3, 5, 24, '2025-06-05 16:11:00', '2025-06-05 18:15:00', 45, 1, 1, 1, NOW()),
(3, 5, 25, '2025-06-05 18:30:00', '2025-06-05 21:42:00', 60, 1, 1, 1, NOW()),
(3, 5, 26, '2025-06-06 09:00:00', '2025-06-06 11:41:00', 50, 1, 1, 1, NOW()),
(3, 5, 27, '2025-06-06 11:56:00', '2025-06-06 13:55:00', 45, 1, 1, 1, NOW()),
(3, 5, 28, '2025-06-06 14:10:00', '2025-06-06 16:16:00', 45, 1, 1, 1, NOW()),
(3, 5, 29, '2025-06-06 16:31:00', '2025-06-06 17:58:00', 40, 1, 1, 1, NOW()),
(3, 5, 30, '2025-06-06 18:13:00', '2025-06-06 19:40:00', 40, 1, 1, 1, NOW()),
(3, 5, 1, '2025-06-07 09:00:00', '2025-06-07 11:24:00', 45, 1, 1, 1, NOW()),
(3, 5, 2, '2025-06-07 11:39:00', '2025-06-07 13:55:00', 45, 1, 1, 1, NOW()),
(3, 5, 3, '2025-06-07 14:10:00', '2025-06-07 16:34:00', 45, 1, 1, 1, NOW()),
(3, 5, 4, '2025-06-07 16:49:00', '2025-06-07 19:15:00', 50, 1, 1, 1, NOW()),
(3, 5, 5, '2025-06-07 19:30:00', '2025-06-07 21:18:00', 45, 1, 1, 1, NOW()),
(3, 5, 6, '2025-06-07 21:33:00', '2025-06-07 23:42:00', 45, 1, 1, 1, NOW()),
-- 丁丁影城 (cinema_id=4, hall: 6) - 40场
(4, 6, 1, '2025-06-01 09:00:00', '2025-06-01 11:24:00', 45, 1, 1, 1, NOW()),
(4, 6, 2, '2025-06-01 11:39:00', '2025-06-01 13:55:00', 45, 1, 1, 1, NOW()),
(4, 6, 3, '2025-06-01 14:10:00', '2025-06-01 16:34:00', 45, 1, 1, 1, NOW()),
(4, 6, 4, '2025-06-01 16:49:00', '2025-06-01 19:15:00', 50, 1, 1, 1, NOW()),
(4, 6, 5, '2025-06-01 19:30:00', '2025-06-01 21:18:00', 45, 1, 1, 1, NOW()),
(4, 6, 6, '2025-06-02 09:00:00', '2025-06-02 11:09:00', 40, 1, 1, 1, NOW()),
(4, 6, 7, '2025-06-02 11:24:00', '2025-06-02 13:25:00', 40, 1, 1, 1, NOW()),
(4, 6, 8, '2025-06-02 13:40:00', '2025-06-02 15:54:00', 45, 1, 1, 1, NOW()),
(4, 6, 9, '2025-06-02 16:09:00', '2025-06-02 18:37:00', 45, 1, 1, 1, NOW()),
(4, 6, 10, '2025-06-02 18:52:00', '2025-06-02 21:31:00', 55, 1, 1, 1, NOW()),
(4, 6, 11, '2025-06-03 09:00:00', '2025-06-03 10:52:00', 40, 1, 1, 1, NOW()),
(4, 6, 12, '2025-06-03 11:07:00', '2025-06-03 13:55:00', 50, 1, 1, 1, NOW()),
(4, 6, 13, '2025-06-03 14:10:00', '2025-06-03 16:07:00', 45, 1, 1, 1, NOW()),
(4, 6, 14, '2025-06-03 16:22:00', '2025-06-03 18:23:00', 45, 1, 1, 1, NOW()),
(4, 6, 15, '2025-06-03 18:38:00', '2025-06-03 20:48:00', 50, 1, 1, 1, NOW()),
(4, 6, 16, '2025-06-04 09:00:00', '2025-06-04 11:46:00', 50, 1, 1, 1, NOW()),
(4, 6, 17, '2025-06-04 12:01:00', '2025-06-04 13:56:00', 45, 1, 1, 1, NOW()),
(4, 6, 18, '2025-06-04 14:11:00', '2025-06-04 15:45:00', 40, 1, 1, 1, NOW()),
(4, 6, 19, '2025-06-04 16:00:00', '2025-06-04 17:59:00', 45, 1, 1, 1, NOW()),
(4, 6, 20, '2025-06-04 18:14:00', '2025-06-04 21:14:00', 60, 1, 1, 1, NOW()),
(4, 6, 21, '2025-06-05 09:00:00', '2025-06-05 10:54:00', 40, 1, 1, 1, NOW()),
(4, 6, 22, '2025-06-05 11:09:00', '2025-06-05 13:39:00', 45, 1, 1, 1, NOW()),
(4, 6, 23, '2025-06-05 13:54:00', '2025-06-05 15:56:00', 45, 1, 1, 1, NOW()),
(4, 6, 24, '2025-06-05 16:11:00', '2025-06-05 18:15:00', 45, 1, 1, 1, NOW()),
(4, 6, 25, '2025-06-05 18:30:00', '2025-06-05 21:42:00', 60, 1, 1, 1, NOW()),
(4, 6, 26, '2025-06-06 09:00:00', '2025-06-06 11:41:00', 50, 1, 1, 1, NOW()),
(4, 6, 27, '2025-06-06 11:56:00', '2025-06-06 13:55:00', 45, 1, 1, 1, NOW()),
(4, 6, 28, '2025-06-06 14:10:00', '2025-06-06 16:16:00', 45, 1, 1, 1, NOW()),
(4, 6, 29, '2025-06-06 16:31:00', '2025-06-06 17:58:00', 40, 1, 1, 1, NOW()),
(4, 6, 30, '2025-06-06 18:13:00', '2025-06-06 19:40:00', 40, 1, 1, 1, NOW()),
(4, 6, 1, '2025-06-07 09:00:00', '2025-06-07 11:24:00', 45, 1, 1, 1, NOW()),
(4, 6, 2, '2025-06-07 11:39:00', '2025-06-07 13:55:00', 45, 1, 1, 1, NOW()),
(4, 6, 3, '2025-06-07 14:10:00', '2025-06-07 16:34:00', 45, 1, 1, 1, NOW()),
(4, 6, 4, '2025-06-07 16:49:00', '2025-06-07 19:15:00', 50, 1, 1, 1, NOW()),
(4, 6, 5, '2025-06-07 19:30:00', '2025-06-07 21:18:00', 45, 1, 1, 1, NOW());

-- ============================================================
-- 公告数据
-- ============================================================
INSERT INTO t_notice (id, title, content, publish_status, publish_time, publisher_admin_id)
VALUES
  (1, '系统公告：欢迎使用电影购票系统', '为确保良好体验，请合理安排观影时间并遵守影院规定。', 1, NOW(), 1);

SET FOREIGN_KEY_CHECKS = 1;
