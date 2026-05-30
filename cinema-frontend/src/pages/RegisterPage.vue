<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { register as registerApi } from '@/api/auth'

const router = useRouter()

const loading = ref(false)

const form = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  nickname: '',
  phone: '',
})

async function onSubmit() {
  if (!form.username || !form.password || !form.confirmPassword || !form.nickname || !form.phone) {
    ElMessage.error('请填写完整信息')
    return
  }
  if (form.password !== form.confirmPassword) {
    ElMessage.error('两次输入的密码不一致')
    return
  }
  loading.value = true
  try {
    await registerApi({
      username: form.username,
      password: form.password,
      nickname: form.nickname,
      phone: form.phone,
    })
    ElMessage.success('注册成功，请登录')
    await router.replace('/login')
  } catch (e: any) {
    ElMessage.error(e?.message || '注册失败')
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
        <div class="text-sm text-white/70 mt-1">用户注册</div>
      </div>

      <el-card shadow="never" class="rounded-xl">
        <el-form label-position="top" @submit.prevent>
          <el-form-item label="用户名">
            <el-input v-model="form.username" placeholder="请输入用户名" autocomplete="username" />
          </el-form-item>

          <el-form-item label="密码">
            <el-input
              v-model="form.password"
              placeholder="请输入密码"
              type="password"
              show-password
              autocomplete="new-password"
            />
          </el-form-item>

          <el-form-item label="确认密码">
            <el-input
              v-model="form.confirmPassword"
              placeholder="请再次输入密码"
              type="password"
              show-password
              autocomplete="new-password"
              @keyup.enter="onSubmit"
            />
          </el-form-item>

          <el-form-item label="昵称">
            <el-input v-model="form.nickname" placeholder="请输入昵称" autocomplete="nickname" />
          </el-form-item>

          <el-form-item label="手机号">
            <el-input v-model="form.phone" placeholder="请输入手机号" autocomplete="tel" />
          </el-form-item>

          <el-button type="primary" class="w-full" :loading="loading" @click="onSubmit">注册</el-button>

          <div class="mt-4 text-center text-sm text-slate-500">
            已有账号？
            <router-link to="/login" class="text-blue-600 hover:text-blue-500">立即登录</router-link>
          </div>
        </el-form>
      </el-card>
    </div>
  </div>
</template>
