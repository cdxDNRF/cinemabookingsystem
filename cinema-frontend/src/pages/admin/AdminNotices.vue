<script setup lang="ts">
import { reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { api } from '@/api/client'

const loading = ref(false)
const list = ref<any[]>([])
const form = reactive({ title: '', content: '' })

async function load() {
  loading.value = true
  try {
    list.value = await api.get('/api/admin/notices')
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

async function create() {
  if (!form.title || !form.content) {
    ElMessage.warning('请填写标题与内容')
    return
  }
  try {
    await api.post('/api/admin/notices', { ...form, publishStatus: 1 })
    ElMessage.success('已发布')
    form.title = ''
    form.content = ''
    load()
  } catch (e: any) {
    ElMessage.error(e?.message || '发布失败')
  }
}

async function remove(id: number) {
  try {
    await api.delete(`/api/admin/notices/${id}`)
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
    <div class="text-base font-semibold">公告管理</div>
    <div class="mt-4" style="max-width: 860px">
      <el-input v-model="form.title" placeholder="标题" />
      <el-input v-model="form.content" type="textarea" rows="4" placeholder="内容" class="mt-3" />
      <el-button type="primary" class="mt-3" @click="create">发布公告</el-button>
    </div>
  </el-card>

  <el-card shadow="never" class="mt-4">
    <el-table :data="list" size="small" :loading="loading" style="width: 100%">
      <el-table-column prop="id" label="ID" width="90" />
      <el-table-column prop="title" label="标题" />
      <el-table-column prop="createdTime" label="时间" width="180" />
      <el-table-column label="操作" width="120">
        <template #default="scope">
          <el-button size="small" type="danger" plain @click="remove(scope.row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>
</template>

