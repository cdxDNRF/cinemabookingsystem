<script setup lang="ts">
import { reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { api } from '@/api/client'

type Showing = any

const loading = ref(false)
const list = ref<Showing[]>([])

const form = reactive({
  movieId: null as number | null,
  hallId: null as number | null,
  startTime: '',
  endTime: '',
  ticketPrice: 35,
})

const movies = ref<any[]>([])
const halls = ref<any[]>([])

async function loadMeta() {
  try {
    movies.value = await api.get('/api/movies')
  } catch {
  }
  try {
    halls.value = await api.get('/api/cinema-admin/halls')
  } catch {
  }
}

async function load() {
  loading.value = true
  try {
    list.value = await api.get('/api/cinema-admin/showings')
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

async function create() {
  if (!form.movieId || !form.hallId || !form.startTime || !form.endTime) {
    ElMessage.warning('请完整填写信息')
    return
  }
  try {
    await api.post('/api/cinema-admin/showings', {
      movieId: form.movieId,
      hallId: form.hallId,
      startTime: form.startTime,
      endTime: form.endTime,
      ticketPrice: form.ticketPrice,
    })
    ElMessage.success('已提交场次，等待审核')
    load()
  } catch (e: any) {
    ElMessage.error(e?.message || '提交失败')
  }
}

loadMeta()
load()
</script>

<template>
  <el-card shadow="never">
    <div class="text-base font-semibold">场次管理</div>
    <div class="mt-4 grid grid-cols-1 md:grid-cols-2 gap-3" style="max-width: 860px">
      <el-select v-model="form.movieId" placeholder="选择影片">
        <el-option v-for="m in movies" :key="m.id" :label="m.name" :value="m.id" />
      </el-select>
      <el-select v-model="form.hallId" placeholder="选择影厅">
        <el-option v-for="h in halls" :key="h.id" :label="h.name" :value="h.id" />
      </el-select>
      <el-input v-model="form.startTime" placeholder="开始时间：yyyy-MM-dd HH:mm:ss" />
      <el-input v-model="form.endTime" placeholder="结束时间：yyyy-MM-dd HH:mm:ss" />
      <el-input-number v-model="form.ticketPrice" :min="0" :step="1" />
      <el-button type="primary" @click="create">提交场次</el-button>
    </div>
  </el-card>

  <el-card shadow="never" class="mt-4">
    <el-table :data="list" size="small" :loading="loading" style="width: 100%">
      <el-table-column prop="id" label="ID" width="90" />
      <el-table-column prop="movieId" label="影片ID" width="110" />
      <el-table-column prop="hallId" label="影厅ID" width="110" />
      <el-table-column prop="startTime" label="开始" width="170" />
      <el-table-column prop="endTime" label="结束" width="170" />
      <el-table-column prop="ticketPrice" label="票价" width="90" />
      <el-table-column prop="auditStatus" label="审核" width="90" />
    </el-table>
  </el-card>
</template>

