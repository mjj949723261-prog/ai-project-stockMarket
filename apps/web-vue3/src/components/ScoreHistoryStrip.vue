<template>
  <section class="panel">
    <div class="row">
      <h3 class="section-title" style="margin: 0">最近评分变化</h3>
      <span class="muted">{{ history[0] }} -> {{ history[history.length - 1] }}</span>
    </div>
    <div class="history-strip">
      <div
        v-for="(point, index) in history"
        :key="`${point}-${index}`"
        class="history-bar"
        :style="{ height: `${Math.max(12, point)}px` }"
      >
        <span>{{ point }}</span>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
defineProps<{
  history: number[];
}>();
</script>

