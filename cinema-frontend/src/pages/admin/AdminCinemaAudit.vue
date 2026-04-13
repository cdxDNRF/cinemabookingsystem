<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { api } from '@/api/client'

const loading = ref(false)
const list = ref<any[]>([])
const rejectReason = ref('')

async function load() {
  loading.value = true
  try {
    list.value = await api.get('/api/admin/cinema-admins/pending')
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

async function audit(id: number, approved: boolean) {
  try {
    await api.post(`/api/admin/cinema-admins/${id}/audit`, {
      pass: approved,
      reason: approved ? undefined : rejectReason.value || '不通过',
    })
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
      <div class="text-base font-semibold">影院审核</div>
      <el-button size="small" :loading="loading" @click="load">刷新</el-button>
    </div>
  </el-card>

  <el-card shadow="never" class="mt-4">
    <div class="flex items-center gap-3 mb-3">
      <el-input v-model="rejectReason" placeholder="拒绝原因（可选）" style="width: 320px" />
    </div>
    <el-table :data="list" size="small" :loading="loading" style="width: 100%">
      <el-table-column prop="id" label="ID" width="90" />
      <el-table-column prop="username" label="账号" width="160" />
      <el-table-column prop="realName" label="姓名" width="160" />
      <el-table-column prop="auditStatus" label="审核" width="90" />
      <el-table-column label="操作" width="200">
        <template #default="scope">
          <el-button size="small" type="primary" @click="audit(scope.row.id, true)">通过</el-button>
          <el-button size="small" type="danger" plain @click="audit(scope.row.id, false)">拒绝</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>
</template>

