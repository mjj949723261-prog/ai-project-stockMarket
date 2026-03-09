<template>
  <span class="trend-badge">{{ label }}</span>
</template>

<script setup lang="ts">
import { computed } from "vue";
import type { ScoreTrend } from "../types/stock";

const props = defineProps<{
  trend: ScoreTrend;
}>();

const label = computed(() => {
  if (props.trend === "up") return "上升";
  if (props.trend === "down") return "下降";
  return "持平";
});
</script>

