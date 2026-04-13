export type ApiResult<T> = {
    code: number
    message: string
    data: T
}

export type RoleType = 'ADMIN' | 'CINEMA_ADMIN' | 'USER'

export type LoginResponse = {
    token: string
    role: RoleType
    userId: number
    username: string
    nickname: string
    cinemaId: number | null
}

