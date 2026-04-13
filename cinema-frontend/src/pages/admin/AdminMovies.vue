<script setup lang="ts">
import { reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { api } from '@/api/client'

type MovieType = { id: number; name: string }

const loading = ref(false)
const keyword = ref('')
const status = ref<number | null>(null)
const list = ref<any[]>([])
const types = ref<MovieType[]>([])

const dialogOpen = ref(false)
const saving = ref(false)
const form = reactive({
  id: null as number | null,
  name: '',
  nameEn: '',
  posterUrl: '',
  region: '',
  year: null as number | null,
  language: '',
  releaseDate: '' as string,
  durationMin: null as number | null,
  intro: '',
  status: 1 as number,
  typeIds: [] as number[],
})

function resetForm() {
  form.id = null
  form.name = ''
  form.nameEn = ''
  form.posterUrl = ''
  form.region = ''
  form.year = null
  form.language = ''
  form.releaseDate = ''
  form.durationMin = null
  form.intro = ''
  form.status = 1
  form.typeIds = []
}

async function loadTypes() {
  try {
    types.value = (await api.get('/api/movies/types')) as unknown as MovieType[]
  } catch {
  }
}

async function load() {
  loading.value = true
  try {
    list.value = await api.get('/api/admin/movies', {
      params: {
        status: status.value ?? undefined,
        keyword: keyword.value || undefined,
      },
    })
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

function openCreate() {
  resetForm()
  dialogOpen.value = true
}

function openEdit(row: any) {
  resetForm()
  form.id = Number(row.id)
  form.name = row.name ?? ''
  form.nameEn = row.nameEn ?? ''
  form.posterUrl = row.posterUrl ?? ''
  form.region = row.region ?? ''
  form.year = row.year ?? null
  form.language = row.language ?? ''
  form.releaseDate = row.releaseDate ? String(row.releaseDate).slice(0, 10) : ''
  form.durationMin = row.durationMin ?? null
  form.intro = row.intro ?? ''
  form.status = row.status ?? 1
  form.typeIds = Array.isArray(row.typeIds) ? row.typeIds : []
  dialogOpen.value = true
}

async function save() {
  if (!form.name) {
    ElMessage.warning('请输入影片名称')
    return
  }
  saving.value = true
  try {
    await api.post('/api/admin/movies', {
      id: form.id ?? undefined,
      name: form.name,
      nameEn: form.nameEn || undefined,
      posterUrl: form.posterUrl || undefined,
      region: form.region || undefined,
      year: form.year ?? undefined,
      language: form.language || undefined,
      releaseDate: form.releaseDate || undefined,
      durationMin: form.durationMin ?? undefined,
      intro: form.intro || undefined,
      status: form.status,
      typeIds: form.typeIds.length ? form.typeIds : undefined,
    })
    ElMessage.success('已保存')
    dialogOpen.value = false
    load()
  } catch (e: any) {
    ElMessage.error(e?.message || '保存失败')
  } finally {
    saving.value = false
  }
}

async function remove(id: number) {
  try {
    await ElMessageBox.confirm('确认删除该影片？', '提示', { type: 'warning' })
    await api.delete(`/api/admin/movies/${id}`)
    ElMessage.success('已删除')
    load()
  } catch {
  }
}

loadTypes()
load()
</script>

<template>
  <el-card shadow="never">
    <div class="flex items-center gap-3 flex-wrap">
      <el-input v-model="keyword" placeholder="搜索影片" style="width: 260px" @keyup.enter="load" />
      <el-select v-model="status" placeholder="状态" style="width: 140px">
        <el-option :value="null" label="全部" />
        <el-option :value="1" label="上映中" />
        <el-option :value="0" label="待上映" />
        <el-option :value="-1" label="下架" />
      </el-select>
      <el-button type="primary" :loading="loading" @click="load">查询</el-button>
      <el-button type="primary" plain @click="openCreate">新增影片</el-button>
    </div>
  </el-card>

  <el-card shadow="never" class="mt-4">
    <el-table :data="list" size="small" :loading="loading" style="width: 100%">
      <el-table-column prop="id" label="ID" width="90" />
      <el-table-column prop="name" label="影片" min-width="200" />
      <el-table-column prop="status" label="状态" width="100" />
      <el-table-column prop="year" label="年份" width="90" />
      <el-table-column prop="region" label="地区" width="120" />
      <el-table-column prop="durationMin" label="时长" width="90" />
      <el-table-column prop="totalBoxOffice" label="票房" width="120" />
      <el-table-column label="操作" width="180">
        <template #default="scope">
          <el-button size="small" @click="openEdit(scope.row)">编辑</el-button>
          <el-button size="small" type="danger" plain @click="remove(scope.row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>

  <el-dialog v-model="dialogOpen" :title="form.id ? '编辑影片' : '新增影片'" width="860px">
    <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
      <el-form-item label="影片名称">
        <el-input v-model="form.name" />
      </el-form-item>
      <el-form-item label="英文名">
        <el-input v-model="form.nameEn" />
      </el-form-item>
      <el-form-item label="海报 URL">
        <el-input v-model="form.posterUrl" />
      </el-form-item>
      <el-form-item label="地区">
        <el-input v-model="form.region" />
      </el-form-item>
      <el-form-item label="年份">
        <el-input-number v-model="form.year" :min="1900" :max="2100" controls-position="right" class="w-full" />
      </el-form-item>
      <el-form-item label="语言">
        <el-input v-model="form.language" />
      </el-form-item>
      <el-form-item label="上映日期">
        <el-date-picker v-model="form.releaseDate" type="date" value-format="YYYY-MM-DD" class="w-full" />
      </el-form-item>
      <el-form-item label="时长（分钟）">
        <el-input-number v-model="form.durationMin" :min="1" :max="500" controls-position="right" class="w-full" />
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="form.status" class="w-full">
          <el-option :value="1" label="上映中" />
          <el-option :value="0" label="待上映" />
          <el-option :value="-1" label="下架" />
        </el-select>
      </el-form-item>
      <el-form-item label="类型">
        <el-select v-model="form.typeIds" multiple filterable class="w-full">
          <el-option v-for="t in types" :key="t.id" :value="t.id" :label="t.name" />
        </el-select>
      </el-form-item>
    </div>
    <el-form-item label="简介" class="mt-3">
      <el-input v-model="form.intro" type="textarea" rows="4" />
    </el-form-item>

    <template #footer>
      <el-button @click="dialogOpen = false">取消</el-button>
      <el-button type="primary" :loading="saving" @click="save">保存</el-button>
    </template>
  </el-dialog>
</template>

