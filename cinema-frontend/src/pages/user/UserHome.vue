<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { ElMessage } from 'element-plus'
import { httpGet } from '@/api/client'
import { useRouter } from 'vue-router'
import { Right } from '@element-plus/icons-vue'

type Movie = {
  id: number
  name: string
  posterUrl?: string
  totalBoxOffice?: number
  ratingAvg?: number
  status?: number
}

type HomeResp = {
  hot: Movie[]
  upcoming: Movie[]
  topBoxOffice: Movie[]
  todayBoxOffice: string | number
}

const router = useRouter()
const loading = ref(false)
const data = ref<HomeResp | null>(null)

// 轮播相关
const carouselRef = ref<HTMLElement | null>(null)
const scrollPosition = ref(0)
let scrollInterval: ReturnType<typeof setInterval> | null = null

async function load() {
  loading.value = true
  try {
    data.value = await httpGet<HomeResp>('/api/home')
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

function goDetail(movieId: number) {
  router.push(`/u/movie/${movieId}`)
}

function goMovies() {
  router.push('/u/movies')
}

function getPoster(movie: Movie): string {
  return movie.posterUrl || ''
}

function startAutoScroll() {
  if (scrollInterval) return
  scrollInterval = setInterval(() => {
    if (!carouselRef.value) return
    const container = carouselRef.value
    const maxScroll = container.scrollWidth - container.clientWidth
    if (maxScroll <= 0) return
    scrollPosition.value += 1
    if (scrollPosition.value > maxScroll) {
      scrollPosition.value = 0
    }
    container.scrollLeft = scrollPosition.value
  }, 30)
}

function stopAutoScroll() {
  if (scrollInterval) {
    clearInterval(scrollInterval)
    scrollInterval = null
  }
}

onMounted(() => {
  load()
  startAutoScroll()
})

onUnmounted(() => {
  stopAutoScroll()
})
</script>

<template>
  <div v-loading="loading" class="home-container space-y-6">
    <!-- 正在热播 - 自动滚动海报 -->
    <div class="hot-section">
      <div class="section-header">
        <h2 class="section-title">
          <span class="title-text">正在热播</span>
          <span class="title-count">({{ data?.hot?.length || 0 }}部)</span>
        </h2>
        <a class="more-link" @click="goMovies">
          全部 <el-icon><Right /></el-icon>
        </a>
      </div>
      <div
        ref="carouselRef"
        class="carousel"
        @mouseenter="stopAutoScroll"
        @mouseleave="startAutoScroll"
      >
        <div
          v-for="movie in data?.hot || []"
          :key="movie.id"
          class="carousel-item"
          @click="goDetail(movie.id)"
        >
          <div class="carousel-poster">
            <img
              :src="getPoster(movie)"
              :alt="movie.name"
              class="carousel-img"
              loading="lazy"
              @error="($event.target as HTMLImageElement).style.display='none'"
            />
          </div>
          <div class="carousel-name">{{ movie.name }}</div>
          <el-button size="small" type="primary" class="carousel-btn" @click.stop="goDetail(movie.id)">
            购票
          </el-button>
        </div>
      </div>
    </div>

    <div class="main-grid">
      <!-- 左侧：总票房Top10 -->
      <div class="left-section">
        <div class="section-header">
          <h2 class="section-title">总票房Top 10</h2>
        </div>
        <div class="ranking-list">
          <div
            v-for="(movie, index) in data?.topBoxOffice || []"
            :key="movie.id"
            class="ranking-item"
            @click="goDetail(movie.id)"
          >
            <div class="rank-number" :class="{ 'top-three': index < 3 }">{{ index + 1 }}</div>
            <img
              :src="getPoster(movie)"
              :alt="movie.name"
              class="rank-poster"
              loading="lazy"
              @error="($event.target as HTMLImageElement).style.display='none'"
            />
            <div class="rank-info">
              <div class="rank-name">{{ movie.name }}</div>
            </div>
            <div class="rank-boxoffice">{{ movie.totalBoxOffice || 0 }}万</div>
          </div>
        </div>
      </div>

      <!-- 右侧：今日票房 + 即将上映 -->
      <div class="right-section space-y-4">
        <div class="today-boxoffice-card">
          <div class="today-label">今日票房</div>
          <div class="today-amount">{{ data?.todayBoxOffice ?? '-' }}元</div>
          <div class="today-time">北京时间：{{ new Date().toLocaleString('zh-CN', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit' }) }}</div>
        </div>

        <div class="upcoming-section">
          <div class="section-header">
            <h3 class="section-title">即将上映</h3>
          </div>
          <div class="upcoming-list">
            <div
              v-for="movie in data?.upcoming?.slice(0, 5) || []"
              :key="movie.id"
              class="upcoming-item"
              @click="goDetail(movie.id)"
            >
              <img
                :src="getPoster(movie)"
                :alt="movie.name"
                class="upcoming-poster"
                loading="lazy"
                @error="($event.target as HTMLImageElement).style.display='none'"
              />
              <div class="upcoming-name">{{ movie.name }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.home-container {
  padding: 0 4px;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.section-title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 8px;
}

.title-text {
  color: #ff6b6b;
}

.title-count {
  font-size: 14px;
  color: #999;
  font-weight: normal;
}

.more-link {
  font-size: 14px;
  color: #ff6b6b;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 2px;
}

.more-link:hover {
  color: #ff5252;
}

/* 轮播 */
.hot-section {
  background: white;
  border-radius: 12px;
  padding: 20px;
}

.carousel {
  display: flex;
  gap: 16px;
  overflow-x: auto;
  scroll-behavior: smooth;
  scrollbar-width: none;
  -ms-overflow-style: none;
  padding-bottom: 8px;
}

.carousel::-webkit-scrollbar {
  display: none;
}

.carousel-item {
  flex-shrink: 0;
  width: 160px;
  cursor: pointer;
  text-align: center;
}

.carousel-poster {
  width: 160px;
  height: 220px;
  border-radius: 10px;
  overflow: hidden;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  margin-bottom: 8px;
}

.carousel-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.carousel-item:hover .carousel-img {
  transform: scale(1.05);
}

.carousel-name {
  font-size: 14px;
  color: #333;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  margin-bottom: 6px;
}

.carousel-btn {
  width: 80px;
}

/* 主网格 */
.main-grid {
  display: grid;
  grid-template-columns: 1fr 320px;
  gap: 20px;
}

.left-section,
.right-section {
  background: white;
  border-radius: 12px;
  padding: 20px;
}

/* 排行榜 */
.ranking-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.ranking-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px;
  border-radius: 8px;
  cursor: pointer;
  transition: background 0.2s;
}

.ranking-item:hover {
  background: #f5f5f5;
}

.rank-number {
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 6px;
  background: #e0e0e0;
  color: #666;
  font-size: 14px;
  font-weight: 600;
  flex-shrink: 0;
}

.rank-number.top-three {
  background: #ff6b6b;
  color: white;
}

.rank-poster {
  width: 50px;
  height: 70px;
  border-radius: 6px;
  object-fit: cover;
  flex-shrink: 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.rank-info {
  flex: 1;
  min-width: 0;
}

.rank-name {
  font-size: 14px;
  color: #333;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.rank-boxoffice {
  font-size: 14px;
  color: #ff6b6b;
  font-weight: 600;
  flex-shrink: 0;
}

/* 今日票房卡片 */
.today-boxoffice-card {
  background: linear-gradient(135deg, #ff6b6b 0%, #ff8e8e 100%);
  border-radius: 12px;
  padding: 20px;
  color: white;
  text-align: center;
}

.today-label {
  font-size: 14px;
  opacity: 0.9;
  margin-bottom: 8px;
}

.today-amount {
  font-size: 28px;
  font-weight: bold;
  margin-bottom: 8px;
}

.today-time {
  font-size: 12px;
  opacity: 0.8;
}

/* 即将上映 */
.upcoming-section {
  margin-top: 16px;
}

.upcoming-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.upcoming-item {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  padding: 4px;
  border-radius: 6px;
  transition: background 0.2s;
}

.upcoming-item:hover {
  background: #f5f5f5;
}

.upcoming-poster {
  width: 50px;
  height: 70px;
  border-radius: 6px;
  object-fit: cover;
  flex-shrink: 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.upcoming-name {
  font-size: 14px;
  color: #333;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

@media (max-width: 768px) {
  .main-grid {
    grid-template-columns: 1fr;
  }

  .carousel-item {
    width: 120px;
  }

  .carousel-poster {
    width: 120px;
    height: 165px;
  }
}
</style>
