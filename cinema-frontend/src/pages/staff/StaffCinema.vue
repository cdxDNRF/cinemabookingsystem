<script setup lang="ts">
import { reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { api } from '@/api/client'

const loading = ref(false)

const form = reactive({
  name: '',
  address: '',
  phone: '',
  email: '',
  tags: '',
  coverUrl: '',
})

async function submit() {
  if (!form.name || !form.address) {
    ElMessage.warning('请填写影院名称与地址')
    return
  }
  loading.value = true
  try {
    await api.post('/api/cinema-admin/cinema/apply', form)
    ElMessage.success('已提交入驻申请，等待审核')
  } catch (e: any) {
    ElMessage.error(e?.message || '提交失败')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <el-card shadow="never">
    <div class="text-base font-semibold mb-4">影院入驻申请</div>
    <el-form label-position="top" style="max-width: 640px">
      <el-form-item label="影院名称">
        <el-input v-model="form.name" />
      </el-form-item>
      <el-form-item label="地址">
        <el-input v-model="form.address" />
      </el-form-item>
      <el-form-item label="联系电话">
        <el-input v-model="form.phone" />
      </el-form-item>
      <el-form-item label="邮箱">
        <el-input v-model="form.email" />
      </el-form-item>
      <el-form-item label="标签（逗号分隔）">
        <el-input v-model="form.tags" />
      </el-form-item>
      <el-form-item label="封面图 URL">
        <el-input v-model="form.coverUrl" />
      </el-form-item>
      <el-button type="primary" :loading="loading" @click="submit">提交申请</el-button>
    </el-form>
  </el-card>
</template>

