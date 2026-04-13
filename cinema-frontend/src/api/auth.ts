import type { LoginResponse, RoleType } from './types'
import { httpPost } from './client'

export function login(params: { username: string; password: string; role: RoleType }) {
    return httpPost<LoginResponse>('/api/auth/login', params)
}

