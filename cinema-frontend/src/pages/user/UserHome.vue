<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { httpGet } from '@/api/client'

type HomeResp = {
  hot: any[]
  upcoming: any[]
  topBoxOffice: any[]
  todayBoxOffice: string | number
}

const loading = ref(false)
const data = ref<HomeResp | null>(null)

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

load()
</script>

<template>
  <div class="space-y-4">
    <el-card shadow="never">
      <div class="flex items-center justify-between">
        <div class="text-base font-semibold">用户首页</div>
        <el-button size="small" :loading="loading" @click="load">刷新</el-button>
      </div>
      <div class="mt-2 text-sm text-slate-600">今日票房：{{ data?.todayBoxOffice ?? '-' }}</div>
    </el-card>

    <el-card shadow="never">
      <div class="text-sm font-semibold mb-3">票房 TOP10</div>
      <el-table :data="data?.topBoxOffice || []" size="small" style="width: 100%">
        <el-table-column prop="name" label="电影" />
        <el-table-column prop="totalBoxOffice" label="总票房" width="120" />
      </el-table>
    </el-card>
  </div>
</template>

