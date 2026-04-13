import { defineStore } from 'pinia'
import type { LoginResponse, RoleType } from '@/api/types'

type AuthState = {
    token: string
    role: RoleType | null
    userId: number | null
    username: string
    nickname: string
    cinemaId: number | null
}

function readRole(v: string | null): RoleType | null {
    if (v === 'ADMIN' || v === 'CINEMA_ADMIN' || v === 'USER') return v
    return null
}

export const useAuthStore = defineStore('auth', {
    state: (): AuthState => ({
        token: localStorage.getItem('cinema_token') ?? '',
        role: readRole(localStorage.getItem('cinema_role')),
        userId: localStorage.getItem('cinema_userId') ? Number(localStorage.getItem('cinema_userId')) : null,
        username: localStorage.getItem('cinema_username') ?? '',
        nickname: localStorage.getItem('cinema_nickname') ?? '',
        cinemaId: localStorage.getItem('cinema_cinemaId') ? Number(localStorage.getItem('cinema_cinemaId')) : null,
    }),
    getters: {
        isAuthed: (s) => !!s.token && !!s.role,
    },
    actions: {
        setLogin(res: LoginResponse) {
            this.token = res.token
            this.role = res.role
            this.userId = res.userId
            this.username = res.username
            this.nickname = res.nickname
            this.cinemaId = res.cinemaId

            localStorage.setItem('cinema_token', res.token)
            localStorage.setItem('cinema_role', res.role)
            localStorage.setItem('cinema_userId', String(res.userId))
            localStorage.setItem('cinema_username', res.username)
            localStorage.setItem('cinema_nickname', res.nickname)
            if (res.cinemaId == null) {
                localStorage.removeItem('cinema_cinemaId')
            } else {
                localStorage.setItem('cinema_cinemaId', String(res.cinemaId))
            }
        },
        logout() {
            this.token = ''
            this.role = null
            this.userId = null
            this.username = ''
            this.nickname = ''
            this.cinemaId = null

            localStorage.removeItem('cinema_token')
            localStorage.removeItem('cinema_role')
            localStorage.removeItem('cinema_userId')
            localStorage.removeItem('cinema_username')
            localStorage.removeItem('cinema_nickname')
            localStorage.removeItem('cinema_cinemaId')
        },
    },
})

