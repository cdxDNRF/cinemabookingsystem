<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { httpGet, httpPost } from '@/api/client'

type Seat = { row: number; col: number; status: number }
type SeatMapResp = { rows: number; cols: number; grid: number[][] }

type ShowingItem = {
  id: number
  movieName: string
  hallName: string
  startTime: string
  ticketPrice: string | number
}

const route = useRoute()
const router = useRouter()

const showId = Number(route.params.showId)

const loading = ref(false)
const seatMap = ref<SeatMapResp | null>(null)
const showing = ref<ShowingItem | null>(null)
const selected = ref<{ row: number; col: number }[]>([])

const grid = computed(() => {
  if (!seatMap.value) return [] as Seat[][]
  const arr: Seat[][] = []
  for (let r = 1; r <= seatMap.value.rows; r++) {
    const row: Seat[] = []
    for (let c = 1; c <= seatMap.value.cols; c++) {
      const status = Number(seatMap.value.grid?.[r - 1]?.[c - 1] ?? 0)
      row.push({ row: r, col: c, status })
    }
    arr.push(row)
  }
  return arr
})

const totalAmount = computed(() => {
  const price = showing.value ? Number(showing.value.ticketPrice) : 0
  return (price * selected.value.length).toFixed(2)
})

function isSelected(r: number, c: number) {
  return selected.value.some((x) => x.row === r && x.col === c)
}

function toggle(r: number, c: number, status: number) {
  if (status !== 0) return
  if (isSelected(r, c)) {
    selected.value = selected.value.filter((x) => !(x.row === r && x.col === c))
    return
  }
  if (selected.value.length >= 4) {
    ElMessage.warning('单次最多选择 4 个座位')
    return
  }
  selected.value = [...selected.value, { row: r, col: c }]
}

async function loadSeats() {
  loading.value = true
  try {
    seatMap.value = await httpGet<SeatMapResp>(`/api/showings/${showId}/seats`)
  } catch (e: any) {
    ElMessage.error(e?.message || '加载座位失败')
  } finally {
    loading.value = false
  }
}

async function loadShowingFromLastCinema() {
  const lastCinemaId = localStorage.getItem('cinema_lastCinemaId')
  if (!lastCinemaId) return
  try {
    const list = await httpGet<any[]>('/api/showings', {
      params: { cinemaId: Number(lastCinemaId) },
    })
    const found = list.find((x) => Number(x.id) === showId)
    if (found) {
      showing.value = {
        id: found.id,
        movieName: found.movieName,
        hallName: found.hallName,
        startTime: found.startTime,
        ticketPrice: found.ticketPrice,
      }
    }
  } catch {
  }
}

async function createOrder() {
  if (!selected.value.length) {
    ElMessage.warning('请选择座位')
    return
  }
  try {
    const res = await httpPost<any>('/api/user/orders', {
      showingId: showId,
      seats: selected.value,
    })
    ElMessage.success('下单成功，请尽快支付')
    router.push({ path: '/u/orders', query: { orderNo: res.orderNo } })
  } catch (e: any) {
    ElMessage.error(e?.message || '下单失败')
  }
}

loadShowingFromLastCinema()
loadSeats()
</script>

<template>
  <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
    <el-card shadow="never" class="lg:col-span-2">
      <div class="flex items-center justify-between">
        <div class="text-base font-semibold">在线选座</div>
        <el-button size="small" :loading="loading" @click="loadSeats">刷新座位</el-button>
      </div>

      <div class="mt-3 text-sm text-slate-600">
        <span class="mr-4">电影：{{ showing?.movieName ?? '-' }}</span>
        <span class="mr-4">影厅：{{ showing?.hallName ?? '-' }}</span>
        <span>开场：{{ showing?.startTime ?? '-' }}</span>
      </div>

      <div class="mt-6 overflow-auto">
        <div class="inline-block">
          <div v-for="(row, rIdx) in grid" :key="rIdx" class="flex gap-2 mb-2">
            <div
              v-for="seat in row"
              :key="seat.row + '-' + seat.col"
              class="w-8 h-8 rounded-md border flex items-center justify-center text-xs cursor-pointer select-none"
              :class="[
                seat.status !== 0 ? 'bg-slate-200 text-slate-500 cursor-not-allowed' : 'bg-white hover:bg-slate-50',
                isSelected(seat.row, seat.col) ? 'bg-blue-600 text-white border-blue-600 hover:bg-blue-600' : '',
              ]"
              @click="toggle(seat.row, seat.col, seat.status)"
            >
              {{ seat.row }}-{{ seat.col }}
            </div>
          </div>
        </div>
      </div>
    </el-card>

    <el-card shadow="never">
      <div class="text-base font-semibold">结算</div>
      <div class="mt-3 text-sm text-slate-600">票价：{{ showing?.ticketPrice ?? '-' }}</div>
      <div class="mt-3 text-sm">已选座位：</div>
      <div class="mt-2 flex flex-wrap gap-2">
        <el-tag v-for="s in selected" :key="s.row + '-' + s.col" closable @close="toggle(s.row, s.col, 0)">
          {{ s.row }}-{{ s.col }}
        </el-tag>
      </div>
      <div class="mt-4 text-sm">合计：<span class="text-lg font-semibold text-blue-600">¥ {{ totalAmount }}</span></div>
      <el-button type="primary" class="w-full mt-4" @click="createOrder">提交订单</el-button>
    </el-card>
  </div>
</template>

