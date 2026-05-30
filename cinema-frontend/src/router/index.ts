import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import type { RoleType } from '@/api/types'
import LoginPage from '@/pages/LoginPage.vue'
import RegisterPage from '@/pages/RegisterPage.vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import PublicLayout from '@/layouts/PublicLayout.vue'

import UserHome from '@/pages/user/UserHome.vue'
import UserMovies from '@/pages/user/UserMovies.vue'
import MovieDetail from '@/pages/user/MovieDetail.vue'
import UserBooking from '@/pages/user/UserBooking.vue'
import UserOrders from '@/pages/user/UserOrders.vue'

import StaffHome from '@/pages/staff/StaffHome.vue'
import StaffCinema from '@/pages/staff/StaffCinema.vue'
import StaffHalls from '@/pages/staff/StaffHalls.vue'
import StaffShows from '@/pages/staff/StaffShows.vue'
import StaffOrders from '@/pages/staff/StaffOrders.vue'

import AdminHome from '@/pages/admin/AdminHome.vue'
import AdminStats from '@/pages/admin/AdminStats.vue'
import AdminCinemaAudit from '@/pages/admin/AdminCinemaAudit.vue'
import AdminMovies from '@/pages/admin/AdminMovies.vue'
import AdminShows from '@/pages/admin/AdminShows.vue'
import AdminOrders from '@/pages/admin/AdminOrders.vue'
import AdminNotices from '@/pages/admin/AdminNotices.vue'
import AdminAccounts from '@/pages/admin/AdminAccounts.vue'

type RouteMetaRole = {
  requiresAuth?: boolean
  roles?: RoleType[]
  public?: boolean
  guestOnly?: boolean
}

const routes: RouteRecordRaw[] = [
  { path: '/', redirect: '/u' },
  { path: '/login', component: LoginPage, meta: { public: true, guestOnly: true } as RouteMetaRole },
  { path: '/register', component: RegisterPage, meta: { public: true, guestOnly: true } as RouteMetaRole },
  {
    path: '/u',
    component: PublicLayout,
    meta: { public: true } as RouteMetaRole,
    children: [
      { path: '', component: UserHome },
      { path: 'movies', component: UserMovies },
      { path: 'movie/:id', component: MovieDetail },
      { path: 'booking/:showId', component: UserBooking, meta: { requiresAuth: true, roles: ['USER'] } as RouteMetaRole },
      { path: 'orders', component: UserOrders, meta: { requiresAuth: true, roles: ['USER'] } as RouteMetaRole },
    ],
  },
  {
    path: '/staff',
    component: DashboardLayout,
    props: { role: 'CINEMA_ADMIN' },
    meta: { requiresAuth: true, roles: ['CINEMA_ADMIN'] } as RouteMetaRole,
    children: [
      { path: '', component: StaffHome },
      { path: 'cinema', component: StaffCinema },
      { path: 'halls', component: StaffHalls },
      { path: 'shows', component: StaffShows },
      { path: 'orders', component: StaffOrders },
    ],
  },
  {
    path: '/admin',
    component: DashboardLayout,
    props: { role: 'ADMIN' },
    meta: { requiresAuth: true, roles: ['ADMIN'] } as RouteMetaRole,
    children: [
      { path: '', component: AdminHome },
      { path: 'stats', component: AdminStats },
      { path: 'cinema-audit', component: AdminCinemaAudit },
      { path: 'movies', component: AdminMovies },
      { path: 'shows', component: AdminShows },
      { path: 'orders', component: AdminOrders },
      { path: 'notices', component: AdminNotices },
      { path: 'accounts', component: AdminAccounts },
    ],
  },
]

// 创建路由实例
const router = createRouter({
  history: createWebHistory(),
  routes,
})

function roleHome(role: RoleType) {
  if (role === 'USER') return '/u'
  if (role === 'CINEMA_ADMIN') return '/staff'
  return '/admin'
}

router.beforeEach((to) => {
  const auth = useAuthStore()
  const meta = (to.meta ?? {}) as RouteMetaRole

  // 仅访客可访问的页面（登录/注册），已登录用户重定向到首页
  if (meta.guestOnly) {
    if (auth.isAuthed && auth.role) {
      return { path: roleHome(auth.role) }
    }
    return true
  }

  // 公开页面，任何人可访问
  if (meta.public) {
    return true
  }

  // 需要认证的路由
  if (meta.requiresAuth) {
    if (!auth.isAuthed || !auth.role) {
      return { path: '/login', query: { redirect: to.fullPath } }
    }
    if (meta.roles && !meta.roles.includes(auth.role)) {
      return { path: roleHome(auth.role) }
    }
  }
  return true
})

export default router
