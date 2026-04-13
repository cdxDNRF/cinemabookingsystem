<script setup lang="ts">
import { ref } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { httpGet, httpPost } from '@/api/client'

type Order = {
  id: number
  orderNo: string
  showingId: number
  seatCount: number
  totalAmount: string | number
  status: number
  lockExpireTime?: string
  payTime?: string
  createdTime?: string
}

type OrderDetail = {
  order: Order
  seats: { seatRow: number; seatCol: number }[]
}

const route = useRoute()

const orderNo = ref((route.query.orderNo as string) || '')
const loading = ref(false)
const list = ref<OrderDetail[]>([])

function statusText(s: number) {
  if (s === 0) return '待支付'
  if (s === 1) return '待取票'
  if (s === 2) return '已完成'
  if (s === 3) return '已取消'
  if (s === 4) return '超时取消'
  return String(s)
}

async function load() {
  loading.value = true
  try {
    list.value = await httpGet<OrderDetail[]>('/api/user/orders', {
      params: { orderNo: orderNo.value || undefined },
    })
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

async function pay(no: string) {
  try {
    await httpPost(`/api/user/orders/${no}/pay`)
    ElMessage.success('支付成功')
    load()
  } catch (e: any) {
    ElMessage.error(e?.message || '支付失败')
  }
}

async function cancel(no: string) {
  try {
    await httpPost(`/api/user/orders/${no}/cancel`)
    ElMessage.success('已取消')
    load()
  } catch (e: any) {
    ElMessage.error(e?.message || '取消失败')
  }
}

load()
</script>

<template>
  <el-card shadow="never">
    <div class="flex items-center gap-3 flex-wrap">
      <el-input v-model="orderNo" placeholder="订单号" style="width: 260px" @keyup.enter="load" />
      <el-button type="primary" :loading="loading" @click="load">查询</el-button>
    </div>
  </el-card>

  <el-card shadow="never" class="mt-4">
    <el-table :data="list" size="small" style="width: 100%" :loading="loading">
      <el-table-column label="订单号" width="210">
        <template #default="scope">{{ scope.row.order.orderNo }}</template>
      </el-table-column>
      <el-table-column label="状态" width="110">
        <template #default="scope">
          <el-tag :type="scope.row.order.status === 0 ? 'warning' : scope.row.order.status === 1 ? 'success' : 'info'">
            {{ statusText(scope.row.order.status) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="座位" min-width="200">
        <template #default="scope">
          <span v-for="(s, idx) in scope.row.seats" :key="idx" class="mr-2">{{ s.seatRow }}-{{ s.seatCol }}</span>
        </template>
      </el-table-column>
      <el-table-column label="金额" width="110">
        <template #default="scope">¥ {{ scope.row.order.totalAmount }}</template>
      </el-table-column>
      <el-table-column label="操作" width="190">
        <template #default="scope">
          <el-button v-if="scope.row.order.status === 0" size="small" type="primary" @click="pay(scope.row.order.orderNo)">支付</el-button>
          <el-button
            v-if="scope.row.order.status === 0 || scope.row.order.status === 1"
            size="small"
            type="danger"
            plain
            @click="cancel(scope.row.order.orderNo)"
          >
            取消
          </el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>
</template>

