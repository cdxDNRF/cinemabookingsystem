import type { LoginResponse, RoleType } from './types'
import { httpPost } from './client'

export function login(params: { username: string; password: string; role: RoleType }) {
    return httpPost<LoginResponse>('/api/auth/login', params)
}

export function register(params: { username: string; password: string; nickname: string; phone: string }) {
    return httpPost<void>('/api/auth/register/user', params)
}

