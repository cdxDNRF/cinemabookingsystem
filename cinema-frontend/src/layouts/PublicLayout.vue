<script setup lang="ts">
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { Film } from 'lucide-vue-next'

const auth = useAuthStore()
const router = useRouter()

function onLogout() {
  auth.logout()
  router.replace('/login')
}
</script>

<template>
  <div class="min-h-screen bg-slate-50">
    <header class="bg-white border-b border-slate-200">
      <div class="max-w-6xl mx-auto px-4 h-16 flex items-center justify-between">
        <div class="flex items-center gap-3">
          <div class="w-9 h-9 rounded-lg bg-blue-600 flex items-center justify-center">
            <Film class="w-5 h-5 text-white" />
          </div>
          <span class="text-lg font-semibold text-slate-900">Cinema</span>
        </div>

        <nav class="flex items-center gap-6">
          <router-link to="/u" class="text-sm text-slate-600 hover:text-blue-600">首页</router-link>
          <router-link to="/u/movies" class="text-sm text-slate-600 hover:text-blue-600">影片</router-link>
          <router-link to="/u/rankings" class="text-sm text-slate-600 hover:text-blue-600">排行榜</router-link>
        </nav>

        <div class="flex items-center gap-3">
          <template v-if="auth.isAuthed">
            <span class="text-sm text-slate-700">{{ auth.nickname || auth.username }}</span>
            <el-button size="small" @click="onLogout">退出</el-button>
          </template>
          <template v-else>
            <router-link to="/login">
              <el-button size="small" type="primary">登录</el-button>
            </router-link>
            <router-link to="/register">
              <el-button size="small">注册</el-button>
            </router-link>
          </template>
        </div>
      </div>
    </header>

    <main>
      <router-view />
    </main>
  </div>
</template>
