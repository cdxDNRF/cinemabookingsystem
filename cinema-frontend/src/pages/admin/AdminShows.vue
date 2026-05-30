<script setup lang="ts">
import { reactive, ref, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { api } from '@/api/client'

type Showing = {
  id: number
  cinemaId: number
  cinemaName: string
  hallId: number
  hallName: string
  movieId: number
  movieName: string
  moviePosterUrl?: string
  startTime: string
  endTime: string
  ticketPrice: number
  auditStatus: number
}

type Cinema = { id: number; name: string }
type Movie = { id: number; name: string }
type Hall = { id: number; name: string }

const loading = ref(false)
const list = ref<Showing[]>([])
const cinemas = ref<Cinema[]>([])
const movies = ref<Movie[]>([])
const halls = ref<Hall[]>([])

const filterCinemaId = ref<number | null>(null)
const filterMovieId = ref<number | null>(null)
const filterDate = ref<string>('')

const dialogVisible = ref(false)
const isEdit = ref(false)
const editingId = ref<number | null>(null)

const form = reactive({
  cinemaId: null as number | null,
  movieId: null as number | null,
  hallId: null as number | null,
  startTime: '',
  endTime: '',
  ticketPrice: 35,
})

const filteredList = computed(() => {
  return list.value.filter((item) => {
    const matchCinema = filterCinemaId.value ? item.cinemaId === filterCinemaId.value : true
    const matchMovie = filterMovieId.value ? item.movieId === filterMovieId.value : true
    const matchDate = filterDate.value ? item.startTime.startsWith(filterDate.value) : true
    return matchCinema && matchMovie && matchDate
  })
})

function resetForm() {
  form.cinemaId = null
  form.movieId = null
  form.hallId = null
  form.startTime = ''
  form.endTime = ''
  form.ticketPrice = 35
  editingId.value = null
  isEdit.value = false
}

function openEdit(row: Showing) {
  resetForm()
  isEdit.value = true
  editingId.value = row.id
  form.cinemaId = row.cinemaId
  form.movieId = row.movieId
  form.hallId = row.hallId
  form.startTime = row.startTime
  form.endTime = row.endTime
  form.ticketPrice = row.ticketPrice
  dialogVisible.value = true
}

async function loadMeta() {
  try {
    cinemas.value = await api.get('/api/admin/cinemas')
  } catch {
    // ignore
  }
  try {
    movies.value = await api.get('/api/movies')
  } catch {
    // ignore
  }
  try {
    halls.value = await api.get('/api/admin/halls')
  } catch {
    // ignore
  }
}

async function load() {
  loading.value = true
  try {
    const params: any = {}
    if (filterCinemaId.value) params.cinemaId = filterCinemaId.value
    if (filterMovieId.value) params.movieId = filterMovieId.value
    list.value = await api.get('/api/admin/showings', { params })
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

function checkConflict(): string | null {
  const start = new Date(form.startTime).getTime()
  const end = new Date(form.endTime).getTime()
  if (isNaN(start) || isNaN(end)) return null
  if (end <= start) {
    return '结束时间必须晚于开始时间'
  }
  const hallId = form.hallId
  const excludeId = editingId.value
  for (const s of list.value) {
    if (s.hallId !== hallId) continue
    if (excludeId && s.id === excludeId) continue
    const sStart = new Date(s.startTime).getTime()
    const sEnd = new Date(s.endTime).getTime()
    const overlap = start < sEnd && end > sStart
    if (overlap) {
      return `与现有排期冲突：${s.cinemaName} ${s.movieName} (${s.startTime} ~ ${s.endTime})`
    }
  }
  return null
}

async function submit() {
  if (!form.cinemaId || !form.movieId || !form.hallId || !form.startTime || !form.endTime) {
    ElMessage.warning('请完整填写信息')
    return
  }
  const conflict = checkConflict()
  if (conflict) {
    ElMessage.error(conflict)
    return
  }
  try {
    await api.put('/api/admin/showings/' + editingId.value, {
      cinemaId: form.cinemaId,
      movieId: form.movieId,
      hallId: form.hallId,
      startTime: form.startTime,
      endTime: form.endTime,
      ticketPrice: form.ticketPrice,
    })
    ElMessage.success('修改成功')
    dialogVisible.value = false
    load()
  } catch (e: any) {
    ElMessage.error(e?.message || '修改失败')
  }
}

async function remove(row: Showing) {
  try {
    await ElMessageBox.confirm(
      `确定删除排期 "${row.movieName}" (${row.cinemaName} ${row.startTime}) 吗？`,
      '删除确认',
      { confirmButtonText: '删除', cancelButtonText: '取消', type: 'warning' }
    )
    await api.delete('/api/admin/showings/' + row.id)
    ElMessage.success('已删除')
    load()
  } catch (e: any) {
    if (e === 'cancel' || e?.message === 'cancel') return
    ElMessage.error(e?.message || '删除失败')
  }
}

async function audit(id: number, approved: boolean) {
  try {
    await api.post(`/api/admin/showings/${id}/audit`, { pass: approved })
    ElMessage.success('已处理')
    load()
  } catch (e: any) {
    ElMessage.error(e?.message || '处理失败')
  }
}

function auditStatusText(status: number) {
  if (status === 0) return '待审核'
  if (status === 1) return '已通过'
  if (status === 2) return '已拒绝'
  return String(status)
}

function auditStatusType(status: number): any {
  if (status === 0) return 'warning'
  if (status === 1) return 'success'
  if (status === 2) return 'danger'
  return 'info'
}

loadMeta()
load()
</script>

<template>
  <el-card shadow="never">
    <div class="flex items-center justify-between">
      <div class="text-base font-semibold">排期管理</div>
      <div class="flex items-center gap-2">
        <el-select v-model="filterCinemaId" placeholder="按影院筛选" clearable style="width: 160px" @change="load">
          <el-option v-for="c in cinemas" :key="c.id" :label="c.name" :value="c.id" />
        </el-select>
        <el-select v-model="filterMovieId" placeholder="按影片筛选" clearable style="width: 160px" @change="load">
          <el-option v-for="m in movies" :key="m.id" :label="m.name" :value="m.id" />
        </el-select>
        <el-date-picker
          v-model="filterDate"
          type="date"
          placeholder="按日期筛选"
          value-format="YYYY-MM-DD"
          clearable
          style="width: 150px"
        />
        <el-button size="small" :loading="loading" @click="load">刷新</el-button>
      </div>
    </div>
  </el-card>

  <el-card shadow="never" class="mt-4">
    <el-table :data="filteredList" size="small" :loading="loading" style="width: 100%">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="cinemaName" label="影院" width="140" />
      <el-table-column prop="hallName" label="影厅" width="120" />
      <el-table-column prop="movieName" label="影片" width="160" />
      <el-table-column prop="startTime" label="开始时间" width="170" />
      <el-table-column prop="endTime" label="结束时间" width="170" />
      <el-table-column prop="ticketPrice" label="票价" width="90" />
      <el-table-column prop="auditStatus" label="审核状态" width="100">
        <template #default="scope">
          <el-tag size="small" :type="auditStatusType(scope.row.auditStatus)">
            {{ auditStatusText(scope.row.auditStatus) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="240">
        <template #default="scope">
          <el-button
            v-if="scope.row.auditStatus === 0"
            size="small"
            type="primary"
            @click="audit(scope.row.id, true)"
          >通过</el-button>
          <el-button
            v-if="scope.row.auditStatus === 0"
            size="small"
            type="danger"
            plain
            @click="audit(scope.row.id, false)"
          >拒绝</el-button>
          <el-button size="small" @click="openEdit(scope.row)">编辑</el-button>
          <el-button size="small" type="danger" plain @click="remove(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>

  <el-dialog v-model="dialogVisible" title="编辑排期" width="560px">
    <div class="grid grid-cols-1 gap-4">
      <el-select v-model="form.cinemaId" placeholder="选择影院">
        <el-option v-for="c in cinemas" :key="c.id" :label="c.name" :value="c.id" />
      </el-select>
      <el-select v-model="form.movieId" placeholder="选择影片">
        <el-option v-for="m in movies" :key="m.id" :label="m.name" :value="m.id" />
      </el-select>
      <el-select v-model="form.hallId" placeholder="选择影厅">
        <el-option v-for="h in halls" :key="h.id" :label="h.name" :value="h.id" />
      </el-select>
      <el-date-picker
        v-model="form.startTime"
        type="datetime"
        placeholder="选择开始时间"
        value-format="YYYY-MM-DD HH:mm:ss"
        style="width: 100%"
      />
      <el-date-picker
        v-model="form.endTime"
        type="datetime"
        placeholder="选择结束时间"
        value-format="YYYY-MM-DD HH:mm:ss"
        style="width: 100%"
      />
      <el-input-number v-model="form.ticketPrice" :min="0" :step="1" style="width: 100%" />
    </div>
    <template #footer>
      <el-button @click="dialogVisible = false">取消</el-button>
      <el-button type="primary" @click="submit">确定</el-button>
    </template>
  </el-dialog>
</template>
