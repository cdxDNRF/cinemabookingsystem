<script setup lang="ts">
const props = defineProps<{
  src?: string
  alt?: string
}>()

function onError(e: Event) {
  const img = e.target as HTMLImageElement
  img.src = '/default-poster.jpg'
}
</script>

<template>
  <img
    :src="src || '/default-poster.jpg'"
    :alt="alt || '电影海报'"
    class="poster-img"
    loading="lazy"
    @error="onError"
  />
</template>

<style scoped>
.poster-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
</style>
