import { createApp } from 'vue'
import './style.css'
import App from './App.vue'
import router from './router'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import zhCn from 'element-plus/es/locale/lang/zh-cn'
import { createPinia } from 'pinia'

// 创建Vue应用实例
const app = createApp(App)

app.use(createPinia())

app.use(ElementPlus, {
    locale: zhCn,
})

// 使用路由
app.use(router)

// 挂载应用
app.mount('#app')
