<script setup lang="ts">
import { computed, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { httpGet } from '@/api/client'
import { useRouter } from 'vue-router'

type Cinema = { id: number; name: string }
type MovieType = { id: number; name: string }
type Movie = { id: number; name: string; posterUrl?: string; status?: number; totalBoxOffice?: number; ratingAvg?: number }

const router = useRouter()

const cinemas = ref<Cinema[]>([])
const cinemaId = ref<number | null>(null)
const keyword = ref('')
const loading = ref(false)
const movies = ref<Movie[]>([])

// 筛选条件
const types = ref<MovieType[]>([])
const selectedTypeId = ref<number | null>(null)
const selectedYear = ref<number | null>(null)
const selectedRegion = ref<string | null>(null)

// 年份选项（2005-2024）
const yearOptions = Array.from({ length: 20 }, (_, i) => 2005 + i)

// 区域选项
const regionOptions = [
  '中国大陆', '中国台湾', '美国', '英国', '法国', '俄罗斯', '中国香港',
  '中国澳门', '泰国', '韩国', '日本', '印度', '意大利', '西班牙', '德国',
  '波兰', '其他'
]

const canOpen = computed(() => !!cinemaId.value)

function getPoster(movie: Movie): string {
  return movie.posterUrl || ''
}

function onCinemaChange(v: number) {
  localStorage.setItem('cinema_lastCinemaId', String(v))
}

async function loadCinemas() {
  try {
    cinemas.value = await httpGet<Cinema[]>('/api/cinemas')
    if (!cinemaId.value && cinemas.value.length) {
      cinemaId.value = cinemas.value[0].id
      localStorage.setItem('cinema_lastCinemaId', String(cinemaId.value))
    }
  } catch {
  }
}

async function loadTypes() {
  try {
    types.value = await httpGet<MovieType[]>('/api/movies/types')
  } catch {
  }
}

async function loadMovies() {
  loading.value = true
  try {
    movies.value = await httpGet<Movie[]>('/api/movies', {
      params: {
        keyword: keyword.value || undefined,
        typeId: selectedTypeId.value || undefined,
        year: selectedYear.value || undefined,
        region: selectedRegion.value || undefined,
      },
    })
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

function resetFilters() {
  selectedTypeId.value = null
  selectedYear.value = null
  selectedRegion.value = null
  keyword.value = ''
  loadMovies()
}

function goDetail(movieId: number) {
  router.push(`/u/movie/${movieId}`)
}

loadCinemas()
loadTypes()
loadMovies()
</script>

<template>
  <el-card shadow="never">
    <div class="flex items-center gap-3 flex-wrap">
      <el-select v-model="cinemaId" placeholder="选择影院" style="width: 240px" @change="onCinemaChange">
        <el-option v-for="c in cinemas" :key="c.id" :value="c.id" :label="c.name" />
      </el-select>
      <el-input v-model="keyword" placeholder="搜索影片" style="width: 260px" @keyup.enter="loadMovies" />
      <el-button type="primary" :loading="loading" @click="loadMovies">查询</el-button>
      <el-button @click="resetFilters">重置</el-button>
    </div>
  </el-card>

  <!-- 筛选区域 -->
  <el-card shadow="never" class="mt-3">
    <!-- 类型 -->
    <div class="filter-row">
      <span class="filter-label">类型:</span>
      <div class="filter-options">
        <el-button
          :type="selectedTypeId === null ? 'primary' : ''"
          size="small"
          @click="selectedTypeId = null; loadMovies()"
        >
          全部
        </el-button>
        <el-button
          v-for="t in types"
          :key="t.id"
          :type="selectedTypeId === t.id ? 'primary' : ''"
          size="small"
          @click="selectedTypeId = t.id; loadMovies()"
        >
          {{ t.name }}
        </el-button>
      </div>
    </div>

    <!-- 年份 -->
    <div class="filter-row">
      <span class="filter-label">年代:</span>
      <div class="filter-options">
        <el-button
          :type="selectedYear === null ? 'primary' : ''"
          size="small"
          @click="selectedYear = null; loadMovies()"
        >
          全部
        </el-button>
        <el-button
          v-for="y in yearOptions.slice().reverse()"
          :key="y"
          :type="selectedYear === y ? 'primary' : ''"
          size="small"
          @click="selectedYear = y; loadMovies()"
        >
          {{ y }}
        </el-button>
      </div>
    </div>

    <!-- 区域 -->
    <div class="filter-row">
      <span class="filter-label">区域:</span>
      <div class="filter-options">
        <el-button
          :type="selectedRegion === null ? 'primary' : ''"
          size="small"
          @click="selectedRegion = null; loadMovies()"
        >
          全部
        </el-button>
        <el-button
          v-for="r in regionOptions"
          :key="r"
          :type="selectedRegion === r ? 'primary' : ''"
          size="small"
          @click="selectedRegion = r; loadMovies()"
        >
          {{ r }}
        </el-button>
      </div>
    </div>
  </el-card>

  <!-- 电影卡片网格 -->
  <div v-loading="loading" class="movie-grid mt-4">
    <div
      v-for="movie in movies"
      :key="movie.id"
      class="movie-card"
      @click="goDetail(movie.id)"
    >
      <!-- 海报区域 -->
      <div class="movie-poster">
        <img
          :src="getPoster(movie)"
          :alt="movie.name"
          class="poster-img"
          loading="lazy"
          @error="($event.target as HTMLImageElement).style.display='none'"
        />
        <div class="movie-title-overlay">{{ movie.name }}</div>
      </div>
      
      <!-- 信息区域 -->
      <div class="movie-info">
        <h3 class="movie-name">{{ movie.name }}</h3>
        <div class="movie-meta">
          <span class="box-office">票房: {{ movie.totalBoxOffice || 0 }}万</span>
          <span v-if="movie.ratingAvg" class="rating">评分: {{ movie.ratingAvg }}</span>
        </div>
        <el-button 
          size="small" 
          type="primary" 
          class="w-full mt-2"
          @click.stop="goDetail(movie.id)"
        >
          查看详情
        </el-button>
      </div>
    </div>
  </div>

  <!-- 空状态 -->
  <el-empty v-if="!loading && movies.length === 0" description="暂无影片" class="mt-8" />
</template>

<style scoped>
.movie-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 20px;
  padding: 0 4px;
}

.movie-card {
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  cursor: pointer;
  background: white;
}

.movie-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
}

.movie-poster {
  position: relative;
  height: 280px;
  overflow: hidden;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.poster-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.movie-card:hover .poster-img {
  transform: scale(1.05);
}

.movie-title-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 30px 12px 12px;
  background: linear-gradient(transparent, rgba(0, 0, 0, 0.7));
  color: white;
  font-size: 16px;
  font-weight: bold;
  text-align: center;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.movie-info {
  background: white;
  padding: 12px;
}

.movie-name {
  margin: 0 0 8px 0;
  font-size: 15px;
  font-weight: 600;
  color: #333;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.movie-meta {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #666;
  margin-bottom: 4px;
}

.box-office {
  color: #ff6b6b;
}

.rating {
  color: #ffa502;
}

:deep(.el-button) {
  border-radius: 6px;
}

.filter-row {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 12px;
}

.filter-row:last-child {
  margin-bottom: 0;
}

.filter-label {
  flex-shrink: 0;
  font-size: 14px;
  color: #666;
  width: 40px;
  line-height: 28px;
}

.filter-options {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
</style>
