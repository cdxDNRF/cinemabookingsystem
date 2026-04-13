<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { api } from '@/api/client'

const loading = ref(false)
const list = ref<any[]>([])

async function load() {
  loading.value = true
  try {
    list.value = await api.get('/api/admin/showings', { params: { auditStatus: 0 } })
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
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

load()
</script>

<template>
  <el-card shadow="never">
    <div class="flex items-center justify-between">
      <div class="text-base font-semibold">场次审核</div>
      <el-button size="small" :loading="loading" @click="load">刷新</el-button>
    </div>
  </el-card>
  <el-card shadow="never" class="mt-4">
    <el-table :data="list" size="small" :loading="loading" style="width: 100%">
      <el-table-column prop="id" label="ID" width="90" />
      <el-table-column prop="cinemaId" label="影院" width="100" />
      <el-table-column prop="movieId" label="电影" width="100" />
      <el-table-column prop="hallId" label="影厅" width="100" />
      <el-table-column prop="startTime" label="开始" width="170" />
      <el-table-column prop="endTime" label="结束" width="170" />
      <el-table-column label="操作" width="200">
        <template #default="scope">
          <el-button size="small" type="primary" @click="audit(scope.row.id, true)">通过</el-button>
          <el-button size="small" type="danger" plain @click="audit(scope.row.id, false)">拒绝</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>
</template>

