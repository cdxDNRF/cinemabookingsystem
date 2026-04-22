// vite.config.ts
import { defineConfig } from "file:///D:/AIagent/%E8%BD%AF%E4%BB%B6%E5%B7%A5%E7%A8%8B%E9%A1%B9%E7%9B%AE%E4%BD%9C%E4%B8%9A/cinema-frontend/node_modules/vite/dist/node/index.js";
import vue from "file:///D:/AIagent/%E8%BD%AF%E4%BB%B6%E5%B7%A5%E7%A8%8B%E9%A1%B9%E7%9B%AE%E4%BD%9C%E4%B8%9A/cinema-frontend/node_modules/@vitejs/plugin-vue/dist/index.mjs";
import path from "path";
import Inspector from "file:///D:/AIagent/%E8%BD%AF%E4%BB%B6%E5%B7%A5%E7%A8%8B%E9%A1%B9%E7%9B%AE%E4%BD%9C%E4%B8%9A/cinema-frontend/node_modules/unplugin-vue-dev-locator/dist/vite.mjs";
import traeBadgePlugin from "file:///D:/AIagent/%E8%BD%AF%E4%BB%B6%E5%B7%A5%E7%A8%8B%E9%A1%B9%E7%9B%AE%E4%BD%9C%E4%B8%9A/cinema-frontend/node_modules/vite-plugin-trae-solo-badge/dist/vite-plugin.esm.js";
var __vite_injected_original_dirname = "D:\\AIagent\\\u8F6F\u4EF6\u5DE5\u7A0B\u9879\u76EE\u4F5C\u4E1A\\cinema-frontend";
var vite_config_default = defineConfig({
  build: {
    sourcemap: "hidden"
  },
  server: {
    port: 5173,
    proxy: {
      "/api": {
        target: "http://localhost:8080",
        changeOrigin: true
      }
    }
  },
  plugins: [
    vue(),
    Inspector(),
    traeBadgePlugin({
      variant: "dark",
      position: "bottom-right",
      prodOnly: true,
      clickable: true,
      clickUrl: "https://www.trae.ai/solo?showJoin=1",
      autoTheme: true,
      autoThemeTarget: "#app"
    })
  ],
  resolve: {
    alias: {
      "@": path.resolve(__vite_injected_original_dirname, "./src")
      // ✅ 定义 @ = src
    }
  }
});
export {
  vite_config_default as default
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcudHMiXSwKICAic291cmNlc0NvbnRlbnQiOiBbImNvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9kaXJuYW1lID0gXCJEOlxcXFxBSWFnZW50XFxcXFx1OEY2Rlx1NEVGNlx1NURFNVx1N0EwQlx1OTg3OVx1NzZFRVx1NEY1Q1x1NEUxQVxcXFxjaW5lbWEtZnJvbnRlbmRcIjtjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfZmlsZW5hbWUgPSBcIkQ6XFxcXEFJYWdlbnRcXFxcXHU4RjZGXHU0RUY2XHU1REU1XHU3QTBCXHU5ODc5XHU3NkVFXHU0RjVDXHU0RTFBXFxcXGNpbmVtYS1mcm9udGVuZFxcXFx2aXRlLmNvbmZpZy50c1wiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9pbXBvcnRfbWV0YV91cmwgPSBcImZpbGU6Ly8vRDovQUlhZ2VudC8lRTglQkQlQUYlRTQlQkIlQjYlRTUlQjclQTUlRTclQTglOEIlRTklQTElQjklRTclOUIlQUUlRTQlQkQlOUMlRTQlQjglOUEvY2luZW1hLWZyb250ZW5kL3ZpdGUuY29uZmlnLnRzXCI7aW1wb3J0IHsgZGVmaW5lQ29uZmlnIH0gZnJvbSAndml0ZSdcbmltcG9ydCB2dWUgZnJvbSAnQHZpdGVqcy9wbHVnaW4tdnVlJ1xuaW1wb3J0IHBhdGggZnJvbSAncGF0aCdcbmltcG9ydCBJbnNwZWN0b3IgZnJvbSAndW5wbHVnaW4tdnVlLWRldi1sb2NhdG9yL3ZpdGUnXG5pbXBvcnQgdHJhZUJhZGdlUGx1Z2luIGZyb20gJ3ZpdGUtcGx1Z2luLXRyYWUtc29sby1iYWRnZSdcblxuLy8gaHR0cHM6Ly92aXRlLmRldi9jb25maWcvXG5leHBvcnQgZGVmYXVsdCBkZWZpbmVDb25maWcoe1xuICBidWlsZDoge1xuICAgIHNvdXJjZW1hcDogJ2hpZGRlbicsXG4gIH0sXG4gIHNlcnZlcjoge1xuICAgIHBvcnQ6IDUxNzMsXG4gICAgcHJveHk6IHtcbiAgICAgICcvYXBpJzoge1xuICAgICAgICB0YXJnZXQ6ICdodHRwOi8vbG9jYWxob3N0OjgwODAnLFxuICAgICAgICBjaGFuZ2VPcmlnaW46IHRydWUsXG4gICAgICB9LFxuICAgIH0sXG4gIH0sXG4gIHBsdWdpbnM6IFtcbiAgICB2dWUoKSxcbiAgICBJbnNwZWN0b3IoKSxcbiAgICB0cmFlQmFkZ2VQbHVnaW4oe1xuICAgICAgdmFyaWFudDogJ2RhcmsnLFxuICAgICAgcG9zaXRpb246ICdib3R0b20tcmlnaHQnLFxuICAgICAgcHJvZE9ubHk6IHRydWUsXG4gICAgICBjbGlja2FibGU6IHRydWUsXG4gICAgICBjbGlja1VybDogJ2h0dHBzOi8vd3d3LnRyYWUuYWkvc29sbz9zaG93Sm9pbj0xJyxcbiAgICAgIGF1dG9UaGVtZTogdHJ1ZSxcbiAgICAgIGF1dG9UaGVtZVRhcmdldDogJyNhcHAnLFxuICAgIH0pLFxuICBdLFxuICByZXNvbHZlOiB7XG4gICAgYWxpYXM6IHtcbiAgICAgICdAJzogcGF0aC5yZXNvbHZlKF9fZGlybmFtZSwgJy4vc3JjJyksIC8vIFx1MjcwNSBcdTVCOUFcdTRFNDkgQCA9IHNyY1xuICAgIH0sXG4gIH0sXG59KVxuIl0sCiAgIm1hcHBpbmdzIjogIjtBQUFtVyxTQUFTLG9CQUFvQjtBQUNoWSxPQUFPLFNBQVM7QUFDaEIsT0FBTyxVQUFVO0FBQ2pCLE9BQU8sZUFBZTtBQUN0QixPQUFPLHFCQUFxQjtBQUo1QixJQUFNLG1DQUFtQztBQU96QyxJQUFPLHNCQUFRLGFBQWE7QUFBQSxFQUMxQixPQUFPO0FBQUEsSUFDTCxXQUFXO0FBQUEsRUFDYjtBQUFBLEVBQ0EsUUFBUTtBQUFBLElBQ04sTUFBTTtBQUFBLElBQ04sT0FBTztBQUFBLE1BQ0wsUUFBUTtBQUFBLFFBQ04sUUFBUTtBQUFBLFFBQ1IsY0FBYztBQUFBLE1BQ2hCO0FBQUEsSUFDRjtBQUFBLEVBQ0Y7QUFBQSxFQUNBLFNBQVM7QUFBQSxJQUNQLElBQUk7QUFBQSxJQUNKLFVBQVU7QUFBQSxJQUNWLGdCQUFnQjtBQUFBLE1BQ2QsU0FBUztBQUFBLE1BQ1QsVUFBVTtBQUFBLE1BQ1YsVUFBVTtBQUFBLE1BQ1YsV0FBVztBQUFBLE1BQ1gsVUFBVTtBQUFBLE1BQ1YsV0FBVztBQUFBLE1BQ1gsaUJBQWlCO0FBQUEsSUFDbkIsQ0FBQztBQUFBLEVBQ0g7QUFBQSxFQUNBLFNBQVM7QUFBQSxJQUNQLE9BQU87QUFBQSxNQUNMLEtBQUssS0FBSyxRQUFRLGtDQUFXLE9BQU87QUFBQTtBQUFBLElBQ3RDO0FBQUEsRUFDRjtBQUNGLENBQUM7IiwKICAibmFtZXMiOiBbXQp9Cg==
