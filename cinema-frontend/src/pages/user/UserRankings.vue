<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { httpGet } from '@/api/client'
import { useRouter } from 'vue-router'

type Movie = {
  id: number
  name: string
  posterUrl?: string
  totalBoxOffice?: number
  ratingAvg?: number
  ratingCount?: number
  year?: number
  region?: string
  intro?: string
}

const router = useRouter()
const loadingBoxOffice = ref(false)
const loadingRating = ref(false)
const boxOfficeList = ref<Movie[]>([])
const ratingList = ref<Movie[]>([])

async function loadBoxOffice() {
  loadingBoxOffice.value = true
  try {
    boxOfficeList.value = await httpGet<Movie[]>('/api/movies/top/box-office', {
      params: { limit: 10 },
    })
  } catch (e: any) {
    ElMessage.error(e?.message || '加载票房排行失败')
  } finally {
    loadingBoxOffice.value = false
  }
}

async function loadRating() {
  loadingRating.value = true
  try {
    ratingList.value = await httpGet<Movie[]>('/api/movies/top/rating', {
      params: { limit: 10 },
    })
  } catch (e: any) {
    ElMessage.error(e?.message || '加载评分排行失败')
  } finally {
    loadingRating.value = false
  }
}

function goDetail(movieId: number) {
  router.push(`/u/movie/${movieId}`)
}

function getPoster(movie: Movie): string {
  return movie.posterUrl || ''
}

onMounted(() => {
  loadBoxOffice()
  loadRating()
})
</script>

<template>
  <div class="rankings-container">
    <div class="rankings-grid">
      <!-- 总票房Top榜 -->
      <div class="ranking-card">
        <div class="ranking-header">
          <h2 class="ranking-title">总票房 Top榜</h2>
        </div>
        <div v-loading="loadingBoxOffice" class="ranking-body">
          <div
            v-for="(movie, index) in boxOfficeList"
            :key="movie.id"
            class="ranking-row"
            @click="goDetail(movie.id)"
          >
            <div class="rank-badge" :class="{ 'top-three': index < 3 }">
              {{ index + 1 }}
            </div>
            <img
              :src="getPoster(movie)"
              :alt="movie.name"
              class="row-poster"
              loading="lazy"
              @error="($event.target as HTMLImageElement).style.display='none'"
            />
            <div class="row-info">
              <div class="row-name">{{ movie.name }}</div>
              <div class="row-meta">
                <span v-if="movie.region">{{ movie.region }}</span>
                <span v-if="movie.year">{{ movie.year }}年</span>
              </div>
            </div>
            <div class="row-score">
              <span class="score-label">总票房：</span>
              <span class="score-value">{{ movie.totalBoxOffice || 0 }}万</span>
            </div>
          </div>
          <el-empty v-if="!loadingBoxOffice && boxOfficeList.length === 0" description="暂无数据" />
        </div>
      </div>

      <!-- 评分Top榜 -->
      <div class="ranking-card">
        <div class="ranking-header">
          <h2 class="ranking-title">评分 Top榜</h2>
        </div>
        <div v-loading="loadingRating" class="ranking-body">
          <div
            v-for="(movie, index) in ratingList"
            :key="movie.id"
            class="ranking-row"
            @click="goDetail(movie.id)"
          >
            <div class="rank-badge" :class="{ 'top-three': index < 3 }">
              {{ index + 1 }}
            </div>
            <img
              :src="getPoster(movie)"
              :alt="movie.name"
              class="row-poster"
              loading="lazy"
              @error="($event.target as HTMLImageElement).style.display='none'"
            />
            <div class="row-info">
              <div class="row-name">{{ movie.name }}</div>
              <div class="row-meta">
                <span v-if="movie.region">{{ movie.region }}</span>
                <span v-if="movie.year">{{ movie.year }}年</span>
              </div>
            </div>
            <div class="row-score">
              <span class="score-value rating">{{ movie.ratingAvg || 0 }}分</span>
            </div>
          </div>
          <el-empty v-if="!loadingRating && ratingList.length === 0" description="暂无数据" />
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.rankings-container {
  padding: 0 4px;
}

.rankings-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.ranking-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.ranking-header {
  background: linear-gradient(135deg, #f5e6d3 0%, #f0d9b5 100%);
  padding: 16px 20px;
  text-align: center;
}

.ranking-title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #c0392b;
}

.ranking-body {
  padding: 16px;
  min-height: 200px;
}

.ranking-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px;
  border-radius: 8px;
  cursor: pointer;
  transition: background 0.2s;
  margin-bottom: 8px;
}

.ranking-row:last-child {
  margin-bottom: 0;
}

.ranking-row:hover {
  background: #f8f9fa;
}

.rank-badge {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
  background: #e8e8e8;
  color: #666;
  font-size: 14px;
  font-weight: 700;
  flex-shrink: 0;
}

.rank-badge.top-three {
  background: #ff4444;
  color: white;
}

.row-poster {
  width: 56px;
  height: 78px;
  border-radius: 6px;
  object-fit: cover;
  flex-shrink: 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.row-info {
  flex: 1;
  min-width: 0;
}

.row-name {
  font-size: 15px;
  font-weight: 500;
  color: #333;
  margin-bottom: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.row-meta {
  font-size: 12px;
  color: #999;
  display: flex;
  gap: 8px;
}

.row-score {
  flex-shrink: 0;
  text-align: right;
}

.score-label {
  font-size: 13px;
  color: #666;
}

.score-value {
  font-size: 16px;
  font-weight: 700;
  color: #ff4444;
}

.score-value.rating {
  color: #ffa502;
  font-size: 18px;
}

@media (max-width: 768px) {
  .rankings-grid {
    grid-template-columns: 1fr;
  }
}
</style>
