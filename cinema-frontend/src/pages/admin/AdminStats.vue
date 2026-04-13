<script setup lang="ts">
import { onBeforeUnmount, ref } from 'vue'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import { httpGet } from '@/api/client'

const loading = ref(false)
const overview = ref<any>(null)

const lineRef = ref<HTMLElement | null>(null)
const pieRef = ref<HTMLElement | null>(null)
const barRef = ref<HTMLElement | null>(null)

let lineChart: echarts.ECharts | null = null
let pieChart: echarts.ECharts | null = null
let barChart: echarts.ECharts | null = null

async function load() {
  loading.value = true
  try {
    overview.value = await httpGet('/api/admin/stats/overview')

    const line = await httpGet<any>('/api/admin/stats/box-office-last7days')
    const pie = await httpGet<any[]>('/api/admin/stats/type-count')
    const bar = await httpGet<any[]>('/api/admin/stats/type-box-office')

    if (lineRef.value) {
      lineChart = lineChart ?? echarts.init(lineRef.value)
      lineChart.setOption({
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'category', data: line.x },
        yAxis: { type: 'value' },
        series: [{ type: 'line', data: line.y, smooth: true }],
      })
    }

    if (pieRef.value) {
      pieChart = pieChart ?? echarts.init(pieRef.value)
      pieChart.setOption({
        tooltip: { trigger: 'item' },
        series: [
          {
            type: 'pie',
            radius: ['35%', '70%'],
            data: pie.map((x: any) => ({ name: x.typeName, value: x.cnt })),
          },
        ],
      })
    }

    if (barRef.value) {
      barChart = barChart ?? echarts.init(barRef.value)
      barChart.setOption({
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'category', data: bar.map((x: any) => x.typeName) },
        yAxis: { type: 'value' },
        series: [{ type: 'bar', data: bar.map((x: any) => x.amount) }],
      })
    }
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

function resizeAll() {
  lineChart?.resize()
  pieChart?.resize()
  barChart?.resize()
}

window.addEventListener('resize', resizeAll)
onBeforeUnmount(() => window.removeEventListener('resize', resizeAll))

load()
</script>

<template>
  <div class="space-y-4">
    <el-card shadow="never">
      <div class="flex items-center justify-between">
        <div class="text-base font-semibold">统计报表</div>
        <el-button size="small" :loading="loading" @click="load">刷新</el-button>
      </div>
      <div class="mt-4 grid grid-cols-1 md:grid-cols-4 gap-3">
        <el-card shadow="never" class="!border-slate-200">
          <div class="text-xs text-slate-500">电影数量</div>
          <div class="text-2xl font-semibold mt-1">{{ overview?.movieCount ?? '-' }}</div>
        </el-card>
        <el-card shadow="never" class="!border-slate-200">
          <div class="text-xs text-slate-500">影院数量</div>
          <div class="text-2xl font-semibold mt-1">{{ overview?.cinemaCount ?? '-' }}</div>
        </el-card>
        <el-card shadow="never" class="!border-slate-200">
          <div class="text-xs text-slate-500">今日票房</div>
          <div class="text-2xl font-semibold mt-1">{{ overview?.todayBoxOffice ?? '-' }}</div>
        </el-card>
        <el-card shadow="never" class="!border-slate-200">
          <div class="text-xs text-slate-500">总票房</div>
          <div class="text-2xl font-semibold mt-1">{{ overview?.totalBoxOffice ?? '-' }}</div>
        </el-card>
      </div>
    </el-card>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
      <el-card shadow="never">
        <div class="text-sm font-semibold mb-3">近 7 日票房</div>
        <div ref="lineRef" style="height: 320px" />
      </el-card>
      <el-card shadow="never">
        <div class="text-sm font-semibold mb-3">类型数量</div>
        <div ref="pieRef" style="height: 320px" />
      </el-card>
    </div>
    <el-card shadow="never">
      <div class="text-sm font-semibold mb-3">类型票房</div>
      <div ref="barRef" style="height: 320px" />
    </el-card>
  </div>
</template>

