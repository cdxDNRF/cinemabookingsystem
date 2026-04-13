<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import type { RoleType } from '@/api/types'
import {
  Film,
  Ticket,
  LayoutDashboard,
  Shield,
  Building2,
  CalendarDays,
  Megaphone,
  Users,
  ClipboardList,
} from 'lucide-vue-next'

type MenuItem = {
  key: string
  label: string
  icon: any
  to: string
}

const props = defineProps<{ role: RoleType }>()

const auth = useAuthStore()
const route = useRoute()
const router = useRouter()

const collapsed = ref(false)

const menuItems = computed<MenuItem[]>(() => {
  if (props.role === 'USER') {
    return [
      { key: 'u-home', label: '首页', icon: LayoutDashboard, to: '/u' },
      { key: 'u-movies', label: '影片与排期', icon: Film, to: '/u/movies' },
      { key: 'u-orders', label: '我的订单', icon: Ticket, to: '/u/orders' },
    ]
  }
  if (props.role === 'CINEMA_ADMIN') {
    return [
      { key: 'c-home', label: '工作台', icon: LayoutDashboard, to: '/staff' },
      { key: 'c-cinema', label: '影院入驻', icon: Building2, to: '/staff/cinema' },
      { key: 'c-halls', label: '影厅管理', icon: ClipboardList, to: '/staff/halls' },
      { key: 'c-shows', label: '场次管理', icon: CalendarDays, to: '/staff/shows' },
      { key: 'c-orders', label: '订单管理', icon: Ticket, to: '/staff/orders' },
    ]
  }
  return [
    { key: 'a-home', label: '工作台', icon: Shield, to: '/admin' },
    { key: 'a-stats', label: '统计报表', icon: LayoutDashboard, to: '/admin/stats' },
    { key: 'a-audit', label: '影院审核', icon: Building2, to: '/admin/cinema-audit' },
    { key: 'a-movies', label: '影片管理', icon: Film, to: '/admin/movies' },
    { key: 'a-shows', label: '场次审核', icon: CalendarDays, to: '/admin/shows' },
    { key: 'a-orders', label: '订单管理', icon: Ticket, to: '/admin/orders' },
    { key: 'a-notices', label: '公告管理', icon: Megaphone, to: '/admin/notices' },
    { key: 'a-accounts', label: '账号管理', icon: Users, to: '/admin/accounts' },
  ]
})

const active = computed(() => {
  const found = menuItems.value.find((x) => route.path === x.to || route.path.startsWith(x.to + '/'))
  return found?.key
})

const title = computed(() => {
  const found = menuItems.value.find((x) => x.key === active.value)
  return found?.label ?? 'Cinema'
})

function onSelect(index: string) {
  const found = menuItems.value.find((x) => x.key === index)
  if (found) router.push(found.to)
}

function onLogout() {
  auth.logout()
  router.replace('/login')
}
</script>

<template>
  <el-container class="h-screen">
    <el-aside :width="collapsed ? '76px' : '220px'" class="bg-slate-950 text-white">
      <div class="h-16 flex items-center gap-3 px-4 border-b border-white/10">
        <div class="w-9 h-9 rounded-lg bg-white/10 flex items-center justify-center">
          <Film class="w-5 h-5" />
        </div>
        <div v-if="!collapsed" class="leading-tight">
          <div class="text-sm font-semibold">Cinema</div>
          <div class="text-xs text-white/60">管理系统</div>
        </div>
      </div>

      <el-menu
        :default-active="active"
        class="!bg-transparent !border-r-0"
        text-color="rgba(255,255,255,0.82)"
        active-text-color="#ffffff"
        background-color="transparent"
        :collapse="collapsed"
        @select="onSelect"
      >
        <el-menu-item v-for="item in menuItems" :key="item.key" :index="item.key">
          <component :is="item.icon" class="w-4 h-4" />
          <template #title>{{ item.label }}</template>
        </el-menu-item>
      </el-menu>

      <div class="absolute bottom-0 left-0 right-0 p-3 border-t border-white/10">
        <el-button size="small" class="w-full" @click="collapsed = !collapsed">
          {{ collapsed ? '展开' : '收起' }}
        </el-button>
      </div>
    </el-aside>

    <el-container>
      <el-header class="bg-white flex items-center justify-between border-b border-slate-200">
        <div class="font-semibold text-slate-900">{{ title }}</div>
        <div class="flex items-center gap-3">
          <div class="text-sm text-slate-600">{{ auth.nickname || auth.username }}</div>
          <el-dropdown>
            <span class="text-sm text-slate-900 cursor-pointer">账户</span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="onLogout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      <el-main class="p-6">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

