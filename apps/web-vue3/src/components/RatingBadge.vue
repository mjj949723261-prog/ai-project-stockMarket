<template>
  <div class="rating-badge">
    <span class="rating-badge__icon" aria-hidden="true">
      <svg viewBox="0 0 24 24" class="mini-icon">
        <path
          d="M12 2.5l2.9 5.88 6.49.94-4.7 4.58 1.11 6.46L12 17.3l-5.8 3.06 1.1-6.46L2.6 9.32l6.5-.94L12 2.5z"
          fill="currentColor"
        />
      </svg>
    </span>
    <div>
      <div class="rating-badge__label">{{ rating }}</div>
      <div class="rating-badge__meta">置信度：{{ confidenceText }}</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from "vue";
import type { ConfidenceLevel } from "../types/stock";

const props = defineProps<{
  rating: string;
  confidence: ConfidenceLevel;
}>();

const confidenceText = computed(() => {
  if (props.confidence === "high") return "高";
  if (props.confidence === "low") return "低";
  return "中";
});
</script>
