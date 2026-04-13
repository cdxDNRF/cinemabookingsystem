<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { httpDelete, httpGet, httpPost } from '@/api/client'

type Hall = { id: number; name: string; seatRows: number; seatCols: number }

const loading = ref(false)
const list = ref<Hall[]>([])
const name = ref('')

async function load() {
  loading.value = true
  try {
    list.value = await httpGet<Hall[]>('/api/cinema-admin/halls')
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

async function create() {
  if (!name.value) {
    ElMessage.warning('请输入影厅名称')
    return
  }
  try {
    await httpPost('/api/cinema-admin/halls', { name: name.value, seatRows: 8, seatCols: 8 })
    ElMessage.success('已创建')
    name.value = ''
    load()
  } catch (e: any) {
    ElMessage.error(e?.message || '创建失败')
  }
}

async function remove(id: number) {
  try {
    await httpDelete(`/api/cinema-admin/halls/${id}`)
    ElMessage.success('已删除')
    load()
  } catch (e: any) {
    ElMessage.error(e?.message || '删除失败')
  }
}

load()
</script>

<template>
  <el-card shadow="never">
    <div class="flex items-center justify-between">
      <div class="text-base font-semibold">影厅管理</div>
      <el-button size="small" :loading="loading" @click="load">刷新</el-button>
    </div>
    <div class="mt-4 flex items-center gap-3">
      <el-input v-model="name" placeholder="影厅名称" style="width: 260px" />
      <el-button type="primary" @click="create">新增（8×8）</el-button>
    </div>
  </el-card>

  <el-card shadow="never" class="mt-4">
    <el-table :data="list" size="small" :loading="loading" style="width: 100%">
      <el-table-column prop="name" label="影厅" />
      <el-table-column prop="seatRows" label="行" width="90" />
      <el-table-column prop="seatCols" label="列" width="90" />
      <el-table-column label="操作" width="120">
        <template #default="scope">
          <el-button size="small" type="danger" plain @click="remove(scope.row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>
</template>

