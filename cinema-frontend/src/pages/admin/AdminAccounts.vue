<script setup lang="ts">
import { reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { api } from '@/api/client'

const loading = ref(false)
const tab = ref<'users' | 'admins' | 'cinemaAdmins'>('users')

const users = ref<any[]>([])
const admins = ref<any[]>([])
const cinemaAdmins = ref<any[]>([])

const createAdminForm = reactive({ username: '', password: '', nickname: '' })
const createLoading = ref(false)

async function load() {
  loading.value = true
  try {
    users.value = await api.get('/api/admin/manage/users')
    admins.value = await api.get('/api/admin/manage/admins')
    cinemaAdmins.value = await api.get('/api/admin/manage/cinema-admins')
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

async function setStatus(kind: 'users' | 'admins' | 'cinema-admins', id: number, status: number) {
  try {
    await api.post(`/api/admin/manage/${kind}/${id}/status/${status}`)
    ElMessage.success('已更新')
    load()
  } catch (e: any) {
    ElMessage.error(e?.message || '更新失败')
  }
}

async function createAdmin() {
  if (!createAdminForm.username || !createAdminForm.password || !createAdminForm.nickname) {
    ElMessage.warning('请填写完整信息')
    return
  }
  createLoading.value = true
  try {
    await api.post('/api/admin/manage/admins', createAdminForm)
    ElMessage.success('已创建')
    createAdminForm.username = ''
    createAdminForm.password = ''
    createAdminForm.nickname = ''
    load()
  } catch (e: any) {
    ElMessage.error(e?.message || '创建失败')
  } finally {
    createLoading.value = false
  }
}

load()
</script>

<template>
  <el-card shadow="never">
    <div class="flex items-center justify-between">
      <div class="text-base font-semibold">账号管理</div>
      <el-button size="small" :loading="loading" @click="load">刷新</el-button>
    </div>
    <el-tabs v-model="tab" class="mt-3">
      <el-tab-pane label="用户" name="users" />
      <el-tab-pane label="管理员" name="admins" />
      <el-tab-pane label="影院管理员" name="cinemaAdmins" />
    </el-tabs>
  </el-card>

  <el-card v-if="tab === 'admins'" shadow="never" class="mt-4">
    <div class="text-sm font-semibold mb-3">新增管理员</div>
    <div class="flex items-center gap-3 flex-wrap">
      <el-input v-model="createAdminForm.username" placeholder="用户名" style="width: 220px" />
      <el-input v-model="createAdminForm.nickname" placeholder="昵称" style="width: 220px" />
      <el-input v-model="createAdminForm.password" placeholder="密码" style="width: 220px" show-password type="password" />
      <el-button type="primary" :loading="createLoading" @click="createAdmin">创建</el-button>
    </div>
  </el-card>

  <el-card shadow="never" class="mt-4">
    <el-table v-if="tab === 'users'" :data="users" size="small" :loading="loading" style="width: 100%">
      <el-table-column prop="id" label="ID" width="90" />
      <el-table-column prop="username" label="用户名" />
      <el-table-column prop="nickname" label="昵称" width="160" />
      <el-table-column prop="status" label="状态" width="100" />
      <el-table-column label="操作" width="180">
        <template #default="scope">
          <el-button size="small" @click="setStatus('users', scope.row.id, 1)">启用</el-button>
          <el-button size="small" type="danger" plain @click="setStatus('users', scope.row.id, 0)">停用</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-table v-else-if="tab === 'admins'" :data="admins" size="small" :loading="loading" style="width: 100%">
      <el-table-column prop="id" label="ID" width="90" />
      <el-table-column prop="username" label="用户名" />
      <el-table-column prop="nickname" label="昵称" width="160" />
      <el-table-column prop="status" label="状态" width="100" />
      <el-table-column label="操作" width="180">
        <template #default="scope">
          <el-button size="small" @click="setStatus('admins', scope.row.id, 1)">启用</el-button>
          <el-button size="small" type="danger" plain @click="setStatus('admins', scope.row.id, 0)">停用</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-table v-else :data="cinemaAdmins" size="small" :loading="loading" style="width: 100%">
      <el-table-column prop="id" label="ID" width="90" />
      <el-table-column prop="username" label="用户名" />
      <el-table-column prop="nickname" label="昵称" width="160" />
      <el-table-column prop="cinemaId" label="影院ID" width="120" />
      <el-table-column prop="status" label="状态" width="100" />
      <el-table-column label="操作" width="180">
        <template #default="scope">
          <el-button size="small" @click="setStatus('cinema-admins', scope.row.id, 1)">启用</el-button>
          <el-button size="small" type="danger" plain @click="setStatus('cinema-admins', scope.row.id, 0)">停用</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>
</template>

