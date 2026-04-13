<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { api } from '@/api/client'

const loading = ref(false)
const list = ref<any[]>([])

type OrderDetail = {
  order: any
  seats: { seatRow: number; seatCol: number }[]
}

async function load() {
  loading.value = true
  try {
    const rows = (await api.get('/api/cinema-admin/orders')) as unknown as OrderDetail[]
    list.value = rows.map((x) => ({ ...x.order, seats: x.seats }))
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

load()
</script>

<template>
  <el-card shadow="never">
    <div class="flex items-center justify-between">
      <div class="text-base font-semibold">订单管理</div>
      <el-button size="small" :loading="loading" @click="load">刷新</el-button>
    </div>
  </el-card>
  <el-card shadow="never" class="mt-4">
    <el-table :data="list" size="small" :loading="loading" style="width: 100%">
      <el-table-column prop="orderNo" label="订单号" width="210" />
      <el-table-column prop="userId" label="用户" width="100" />
      <el-table-column prop="movieId" label="电影" width="100" />
      <el-table-column prop="seatCount" label="座位" width="90" />
      <el-table-column label="座位明细" min-width="200">
        <template #default="scope">
          <span v-for="(s, idx) in scope.row.seats" :key="idx" class="mr-2">{{ s.seatRow }}-{{ s.seatCol }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="totalAmount" label="金额" width="110" />
      <el-table-column prop="status" label="状态" width="90" />
      <el-table-column prop="createdTime" label="创建时间" width="170" />
    </el-table>
  </el-card>
</template>

