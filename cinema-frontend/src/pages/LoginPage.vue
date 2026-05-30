<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { login as loginApi } from '@/api/auth'
import { useAuthStore } from '@/stores/auth'
import type { RoleType } from '@/api/types'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()

const loading = ref(false)

const form = reactive({
  username: '',
  password: '',
  role: 'USER' as RoleType,
})

function roleHome(role: RoleType) {
  if (role === 'USER') return '/u'
  if (role === 'CINEMA_ADMIN') return '/staff'
  return '/admin'
}

async function onSubmit() {
  if (!form.username || !form.password) {
    ElMessage.error('请输入账号和密码')
    return
  }
  loading.value = true
  try {
    const res = await loginApi({
      username: form.username,
      password: form.password,
      role: form.role,
    })
    auth.setLogin(res)
    const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : ''
    if (redirect && redirect.startsWith(roleHome(res.role))) {
      await router.replace(redirect)
    } else {
      await router.replace(roleHome(res.role))
    }
  } catch (e: any) {
    ElMessage.error(e?.message || '登录失败')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center px-6">
    <div class="absolute inset-0 overflow-hidden">
      <div class="absolute -top-40 -left-40 h-96 w-96 rounded-full bg-blue-500/20 blur-3xl" />
      <div class="absolute top-20 right-10 h-80 w-80 rounded-full bg-indigo-500/20 blur-3xl" />
      <div class="absolute bottom-10 left-1/3 h-96 w-96 rounded-full bg-cyan-500/15 blur-3xl" />
      <div class="absolute inset-0 bg-gradient-to-b from-slate-950 via-slate-900 to-slate-950 opacity-95" />
    </div>

    <div class="relative w-full max-w-md">
      <div class="mb-6 text-center text-white">
        <div class="text-2xl font-semibold tracking-tight">Cinema</div>
        <div class="text-sm text-white/70 mt-1">影院业务系统登录</div>
      </div>

      <el-card shadow="never" class="rounded-xl">
        <el-form label-position="top" @submit.prevent>
          <el-form-item label="角色">
            <el-radio-group v-model="form.role">
              <el-radio-button label="USER">用户</el-radio-button>
              <el-radio-button label="CINEMA_ADMIN">影院管理员</el-radio-button>
              <el-radio-button label="ADMIN">超级管理员</el-radio-button>
            </el-radio-group>
          </el-form-item>

          <el-form-item label="账号">
            <el-input v-model="form.username" placeholder="请输入账号" autocomplete="username" />
          </el-form-item>

          <el-form-item label="密码">
            <el-input
              v-model="form.password"
              placeholder="请输入密码"
              type="password"
              show-password
              autocomplete="current-password"
              @keyup.enter="onSubmit"
            />
          </el-form-item>

          <el-button type="primary" class="w-full" :loading="loading" @click="onSubmit">登录</el-button>

          <div class="mt-4 text-center text-sm text-slate-500">
            还没有账号？
            <router-link to="/register" class="text-blue-600 hover:text-blue-500">立即注册</router-link>
          </div>
        </el-form>
      </el-card>

      <div class="mt-4 text-center text-xs text-white/50">后端接口：/api/*（开发环境已代理到 8080）</div>
    </div>
  </div>
</template>

