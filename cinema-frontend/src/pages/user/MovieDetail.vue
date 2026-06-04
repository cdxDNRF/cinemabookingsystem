<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { httpGet, httpPost } from '@/api/client'
import { useAuthStore } from '@/stores/auth'
import { ArrowLeft, Star, Clock, Calendar, Location, Film } from '@element-plus/icons-vue'

type Movie = {
  id: number
  name: string
  intro: string
  posterUrl?: string
  trailerJson?: string
  status?: number
  totalBoxOffice?: number
  ratingAvg?: number
  ratingCount?: number
  durationMin?: number
  region?: string
  year?: number
  releaseDate?: string
}

type StaffItem = {
  id: number
  movieId: number
  roleType: number
  name: string
  avatarUrl?: string
  sortNo?: number
}

type ShowingItem = {
  id: number
  cinemaId: number
  cinemaName: string
  hallName: string
  movieName: string
  startTime: string
  endTime: string
  ticketPrice: string | number
}

type Comment = {
  id: number
  userName: string
  score: number
  createTime: string
  content: string
}

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const movieId = Number(route.params.id)

const movie = ref<Movie | null>(null)
const movieTypes = ref<any[]>([])
const movieStaff = ref<StaffItem[]>([])
const loading = ref(false)
const showings = ref<ShowingItem[]>([])
const showingsLoading = ref(false)
const comments = ref<Comment[]>([])
const commentsLoading = ref(false)
const activeTab = ref('showings')

const directors = computed(() => movieStaff.value.filter(s => s.roleType === 1))
const actors = computed(() => movieStaff.value.filter(s => s.roleType === 3))

function getPoster(m: Movie | null): string {
  return m?.posterUrl || ''
}

// 解析预告片URL或B站BV号（trailer_json字段存储URL字符串或BV号）
const trailerInfo = computed(() => {
  if (!movie.value?.trailerJson) return null
  const raw = movie.value.trailerJson.trim()
  // 判断是否为B站BV号格式 (BV开头+10位字母数字)
  if (/^BV[a-zA-Z0-9]{10}$/.test(raw)) {
    return { type: 'bilibili', bvid: raw }
  }
  // 否则当作普通视频URL
  return { type: 'video', url: raw }
})

function goBack() {
  router.back()
}

function goBooking(showId: number) {
  if (!authStore.isAuthed) {
    router.push(`/login?redirect=${encodeURIComponent(`/u/movie/${movieId}`)}`)
    return
  }
  router.push(`/u/booking/${showId}`)
}

function goLogin() {
  router.push(`/login?redirect=${encodeURIComponent(`/u/movie/${movieId}`)}`)
}

async function loadMovie() {
  loading.value = true
  try {
    const res = await httpGet<{ movie: Movie; types: any[]; staff: StaffItem[] }>(`/api/movies/${movieId}`)
    movie.value = res.movie
    movieTypes.value = res.types || []
    movieStaff.value = res.staff || []
  } catch (e: any) {
    ElMessage.error(e?.message || '加载影片失败')
  } finally {
    loading.value = false
  }
}

async function loadShowings() {
  showingsLoading.value = true
  try {
    // 查询该电影在所有影院的排期
    showings.value = await httpGet<ShowingItem[]>('/api/showings', {
      params: { movieId },
    })
  } catch (e: any) {
    console.log('加载排期失败:', e)
  } finally {
    showingsLoading.value = false
  }
}

// 按影院分组排期
const groupedShowings = computed(() => {
  const groups: Record<string, ShowingItem[]> = {}
  for (const show of showings.value) {
    const key = show.cinemaName
    if (!groups[key]) groups[key] = []
    groups[key].push(show)
  }
  return groups
})

async function loadComments() {
  commentsLoading.value = true
  try {
    const actions = await httpGet<any[]>(`/api/movies/${movieId}/comments`)
    comments.value = actions
      .filter((a: any) => a.score !== null)
      .map((a: any) => ({
        id: a.id,
        userName: a.userName || a.userId || '匿名用户',
        score: a.score,
        createTime: a.scoreTime || a.createdTime,
        content: a.content || `${a.score}分评价`,
      }))
  } catch (e: any) {
    console.log('加载评论失败:', e)
    comments.value = []
  } finally {
    commentsLoading.value = false
  }
}

const userScore = ref(5)
const userComment = ref('')
const submitting = ref(false)

async function submitComment() {
  if (!userComment.value.trim()) {
    ElMessage.warning('请输入评论内容')
    return
  }
  submitting.value = true
  try {
    await httpPost(`/api/user/movies/${movieId}/score`, {
      score: userScore.value,
      content: userComment.value,
    })
    ElMessage.success('评论发表成功')
    userComment.value = ''
    loadComments()
    loadMovie()
  } catch (e: any) {
    ElMessage.error(e?.message || '发表评论失败')
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  loadMovie()
  loadShowings()
  loadComments()
})
</script>

<template>
  <div v-loading="loading" class="movie-detail">
    <!-- 返回按钮 -->
    <div class="back-bar">
      <el-button :icon="ArrowLeft" text @click="goBack">返回影片列表</el-button>
    </div>

    <div v-if="movie" class="detail-content">
      <!-- 影片头部信息 -->
      <div class="movie-header">
        <div class="poster-section">
          <img
            :src="getPoster(movie)"
            :alt="movie.name"
            class="detail-poster"
            @error="($event.target as HTMLImageElement).style.display='none'"
          />
        </div>
        <div class="info-section">
          <h1 class="movie-title">{{ movie.name }}</h1>
          <div class="rating-bar">
            <el-rate
              :model-value="Number(movie.ratingAvg || 0)"
              disabled
              show-score
              :max="10"
              :colors="['#ff9900', '#ff9900', '#ff9900']"
            />
            <span class="rating-count">{{ movie.ratingCount || 0 }}人评价</span>
          </div>
          <div class="meta-list">
            <div class="meta-item">
              <el-icon><Clock /></el-icon>
              <span>{{ movie.durationMin || 0 }}分钟</span>
            </div>
            <div class="meta-item">
              <el-icon><Location /></el-icon>
              <span>{{ movie.region || '未知' }}</span>
            </div>
            <div class="meta-item">
              <el-icon><Calendar /></el-icon>
              <span>{{ movie.year || '' }}年</span>
            </div>
            <div class="meta-item">
              <el-icon><Film /></el-icon>
              <span>票房: {{ movie.totalBoxOffice || 0 }}万</span>
            </div>
          </div>

          <!-- 导演 -->
          <div v-if="directors.length > 0" class="staff-section">
            <span class="staff-label">导演：</span>
            <span class="staff-names">{{ directors.map(d => d.name).join(' / ') }}</span>
          </div>

          <!-- 主演 -->
          <div v-if="actors.length > 0" class="staff-section">
            <span class="staff-label">主演：</span>
            <span class="staff-names">{{ actors.map(a => a.name).join(' / ') }}</span>
          </div>

          <!-- 类型标签 -->
          <div v-if="movieTypes.length > 0" class="types-section">
            <el-tag v-for="t in movieTypes" :key="t.id" size="small" effect="plain" class="type-tag">
              {{ t.name }}
            </el-tag>
          </div>

          <div class="intro-section">
            <h3>剧情简介</h3>
            <p class="intro-text">{{ movie.intro || '暂无简介' }}</p>
          </div>
        </div>
      </div>

      <!-- 预告片 -->
      <div v-if="trailerInfo" class="trailer-section">
        <h3 class="section-title">预告片</h3>
        <!-- B站嵌入 -->
        <iframe
          v-if="trailerInfo.type === 'bilibili'"
          :src="`//player.bilibili.com/player.html?bvid=${trailerInfo.bvid}&page=1&high_quality=1&danmaku=0`"
          class="trailer-video"
          scrolling="no"
          border="0"
          frameborder="no"
          framespacing="0"
          allowfullscreen
        />
        <!-- 普通视频URL -->
        <video
          v-else
          :src="trailerInfo.url"
          controls
          class="trailer-video"
          preload="metadata"
          :poster="movie?.posterUrl || ''"
        >
          您的浏览器不支持视频播放
        </video>
      </div>

      <!-- 标签页：排期 / 评论 -->
      <el-tabs v-model="activeTab" class="detail-tabs">
        <el-tab-pane label="排期列表" name="showings">
          <div v-loading="showingsLoading">
            <el-empty v-if="showings.length === 0" description="暂无排期" />
            <div v-else class="showing-groups">
              <div
                v-for="(items, cinemaName) in groupedShowings"
                :key="cinemaName"
                class="cinema-group"
              >
                <h3 class="cinema-group-title">{{ cinemaName }}</h3>
                <div class="showing-list">
                  <div
                    v-for="show in items"
                    :key="show.id"
                    class="showing-card"
                  >
                    <div class="showing-info">
                      <div class="showing-time">{{ show.startTime }}</div>
                      <div class="showing-cinema">{{ show.hallName }}</div>
                      <div class="showing-price">¥{{ show.ticketPrice }}</div>
                    </div>
                    <el-button type="primary" @click="goBooking(show.id)">选座购票</el-button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </el-tab-pane>

        <el-tab-pane label="观众评价" name="comments">
          <!-- 发表评论 -->
          <div class="comment-form">
            <h4>发表评价</h4>
            <template v-if="authStore.isAuthed">
              <div class="score-input">
                <span>评分：</span>
                <el-rate v-model="userScore" :max="10" show-score />
              </div>
              <el-input
                v-model="userComment"
                type="textarea"
                :rows="3"
                placeholder="写下你的观影感受..."
                maxlength="200"
                show-word-limit
              />
              <el-button type="primary" :loading="submitting" @click="submitComment" class="submit-btn">
                发表评论
              </el-button>
            </template>
            <template v-else>
              <div class="login-tip">
                <el-button type="primary" @click="goLogin">请登录后发表评论</el-button>
              </div>
            </template>
          </div>

          <!-- 评论列表 -->
          <div v-loading="commentsLoading" class="comments-section">
            <el-empty v-if="comments.length === 0" description="暂无评论" />
            <div v-else class="comment-list">
              <div
                v-for="comment in comments"
                :key="comment.id"
                class="comment-card"
              >
                <div class="comment-header">
                  <span class="comment-user">{{ comment.userName }}</span>
                  <el-rate
                    :model-value="comment.score"
                    disabled
                    :max="10"
                    :colors="['#ff9900', '#ff9900', '#ff9900']"
                  />
                  <span class="comment-time">{{ comment.createTime }}</span>
                </div>
                <p class="comment-content">{{ comment.content }}</p>
              </div>
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>
  </div>
</template>

<style scoped>
.movie-detail {
  padding: 0 4px;
}

.back-bar {
  margin-bottom: 16px;
}

.detail-content {
  background: white;
  border-radius: 12px;
  padding: 24px;
}

.movie-header {
  display: flex;
  gap: 32px;
  margin-bottom: 32px;
}

.poster-section {
  flex-shrink: 0;
}

.detail-poster {
  width: 240px;
  height: 340px;
  object-fit: cover;
  border-radius: 12px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
}

.info-section {
  flex: 1;
}

.movie-title {
  margin: 0 0 16px 0;
  font-size: 28px;
  font-weight: bold;
  color: #333;
}

.rating-bar {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
}

.rating-count {
  color: #999;
  font-size: 14px;
}

.meta-list {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  margin-bottom: 24px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #666;
  font-size: 14px;
}

.staff-section {
  margin-bottom: 10px;
  font-size: 14px;
  line-height: 1.6;
}

.staff-label {
  color: #999;
  margin-right: 4px;
}

.staff-names {
  color: #333;
  font-weight: 500;
}

.types-section {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 16px;
}

.type-tag {
  border-radius: 4px;
}

.intro-section h3 {
  margin: 0 0 12px 0;
  font-size: 18px;
  color: #333;
}

.intro-text {
  margin: 0;
  line-height: 1.8;
  color: #555;
  font-size: 15px;
}

.detail-tabs {
  margin-top: 24px;
}

.showing-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.showing-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  background: #f8f9fa;
  border-radius: 10px;
  transition: background 0.2s;
}

.showing-card:hover {
  background: #eef0f2;
}

.showing-info {
  display: flex;
  align-items: center;
  gap: 24px;
}

.showing-time {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  min-width: 160px;
}

.showing-cinema {
  color: #666;
  font-size: 14px;
  min-width: 200px;
}

.showing-price {
  font-size: 20px;
  font-weight: bold;
  color: #ff6b6b;
}

.showing-groups {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.cinema-group {
  background: white;
  border-radius: 12px;
  padding: 16px;
  border: 1px solid #e8e8e8;
}

.cinema-group-title {
  margin: 0 0 12px 0;
  font-size: 16px;
  font-weight: 600;
  color: #333;
  padding-bottom: 8px;
  border-bottom: 1px solid #eee;
}

.comment-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.comment-card {
  padding: 16px 20px;
  background: #f8f9fa;
  border-radius: 10px;
}

.comment-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.comment-user {
  font-weight: 600;
  color: #333;
}

.comment-time {
  color: #999;
  font-size: 13px;
  margin-left: auto;
}

.comment-content {
  margin: 0;
  color: #555;
  line-height: 1.6;
}

.comment-form {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 10px;
  margin-bottom: 24px;
}

.comment-form h4 {
  margin: 0 0 12px 0;
  color: #333;
}

.score-input {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}

.submit-btn {
  margin-top: 12px;
}

.login-tip {
  display: flex;
  justify-content: center;
  padding: 16px 0;
}

.comments-section {
  margin-top: 20px;
}

.trailer-section {
  margin-bottom: 32px;
  background: white;
  border-radius: 12px;
  padding: 20px;
  border: 1px solid #e8e8e8;
}

.trailer-section .section-title {
  margin: 0 0 16px 0;
  font-size: 18px;
  font-weight: 600;
  color: #333;
}

.trailer-video {
  width: 100%;
  max-width: 800px;
  height: auto;
  aspect-ratio: 16 / 9;
  border-radius: 10px;
  background: #000;
  display: block;
}

@media (max-width: 768px) {
  .movie-header {
    flex-direction: column;
    align-items: center;
  }
  
  .detail-poster {
    width: 200px;
    height: 280px;
  }
  
  .showing-info {
    flex-direction: column;
    gap: 8px;
    align-items: flex-start;
  }
}
</style>
