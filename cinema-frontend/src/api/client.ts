import axios, { AxiosError, type AxiosRequestConfig } from 'axios'
import type { ApiResult } from './types'

export const api = axios.create({
    baseURL: (import.meta as any).env?.VITE_API_BASE_URL || '',
    timeout: 20000,
})

export function httpGet<T>(url: string, config?: AxiosRequestConfig) {
    return api.get(url, config) as unknown as Promise<T>
}

export function httpPost<T>(url: string, data?: any, config?: AxiosRequestConfig) {
    return api.post(url, data, config) as unknown as Promise<T>
}

export function httpDelete<T>(url: string, config?: AxiosRequestConfig) {
    return api.delete(url, config) as unknown as Promise<T>
}

api.interceptors.request.use((config) => {
    const token = localStorage.getItem('cinema_token')
    if (token) {
        config.headers = (config.headers ?? {}) as any
            ; (config.headers as any).Authorization = `Bearer ${token}`
    }
    return config
})

api.interceptors.response.use(
    (resp) => {
        const data = resp.data as ApiResult<unknown>
        if (data && typeof data === 'object' && 'code' in data) {
            if ((data as ApiResult<unknown>).code === 0) {
                return (data as ApiResult<unknown>).data
            }
            const err = new Error((data as ApiResult<unknown>).message)
                ; (err as any).code = (data as ApiResult<unknown>).code
            throw err
        }
        return resp.data
    },
    (error: AxiosError) => {
        const status = error.response?.status
        const payload = error.response?.data as any
        const code = typeof payload?.code === 'number' ? payload.code : status
        const message = payload?.message || error.message || '请求失败'
        const err = new Error(message)
            ; (err as any).code = code

        if (code === 401) {
            localStorage.removeItem('cinema_token')
            localStorage.removeItem('cinema_role')
            localStorage.removeItem('cinema_userId')
            localStorage.removeItem('cinema_username')
            localStorage.removeItem('cinema_nickname')
            localStorage.removeItem('cinema_cinemaId')
            if (!location.pathname.startsWith('/login')) {
                location.href = `/login?redirect=${encodeURIComponent(location.pathname + location.search)}`
            }
        }
        throw err
    }
)

