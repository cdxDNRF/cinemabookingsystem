<script setup lang="ts">
import { computed, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { httpGet } from '@/api/client'
import { useRouter } from 'vue-router'

type Cinema = { id: number; name: string }
type Movie = { id: number; name: string; posterUrl?: string; status?: number; totalBoxOffice?: number }
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

const router = useRouter()

const cinemas = ref<Cinema[]>([])
const cinemaId = ref<number | null>(null)
const keyword = ref('')
const loading = ref(false)
const movies = ref<Movie[]>([])

const drawer = ref(false)
const drawerLoading = ref(false)
const currentMovieId = ref<number | null>(null)
const showings = ref<ShowingItem[]>([])

const canOpen = computed(() => !!cinemaId.value)

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

async function loadMovies() {
  loading.value = true
  try {
    movies.value = await httpGet<Movie[]>('/api/movies', {
      params: { keyword: keyword.value || undefined },
    })
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

async function openShowings(movieId: number) {
  if (!cinemaId.value) {
    ElMessage.warning('请先选择影院')
    return
  }
  drawer.value = true
  drawerLoading.value = true
  currentMovieId.value = movieId
  try {
    showings.value = await httpGet<ShowingItem[]>('/api/showings', {
      params: { cinemaId: cinemaId.value, movieId },
    })
  } catch (e: any) {
    ElMessage.error(e?.message || '加载排期失败')
  } finally {
    drawerLoading.value = false
  }
}

function goBooking(showId: number) {
  router.push(`/u/booking/${showId}`)
}

loadCinemas()
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
    </div>
  </el-card>

  <el-card shadow="never" class="mt-4">
    <el-table :data="movies" size="small" style="width: 100%" :loading="loading">
      <el-table-column prop="name" label="影片" />
      <el-table-column prop="totalBoxOffice" label="总票房" width="120" />
      <el-table-column label="操作" width="160">
        <template #default="scope">
          <el-button size="small" type="primary" :disabled="!canOpen" @click="openShowings(scope.row.id)">查看排期</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>

  <el-drawer v-model="drawer" title="选择场次" size="520px">
    <el-table :data="showings" size="small" :loading="drawerLoading" style="width: 100%">
      <el-table-column prop="startTime" label="开始" width="165" />
      <el-table-column prop="hallName" label="影厅" width="120" />
      <el-table-column prop="ticketPrice" label="票价" width="90" />
      <el-table-column label="" width="110">
        <template #default="scope">
          <el-button size="small" type="primary" @click="goBooking(scope.row.id)">选座</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-drawer>
</template>

