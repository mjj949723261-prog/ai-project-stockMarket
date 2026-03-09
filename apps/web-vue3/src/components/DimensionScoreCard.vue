<template>
  <section class="dimension-card">
    <div class="row">
      <strong>{{ title }}</strong>
      <span class="score-pill">{{ score }}</span>
    </div>
    <div class="row" style="margin-top: 10px">
      <span class="muted">{{ description }}</span>
      <TrendBadge :trend="trend" />
    </div>
    <ul class="reason-list" style="margin: 12px 0 0; padding-left: 18px">
      <li v-for="reason in reasons" :key="reason">{{ reason }}</li>
    </ul>
  </section>
</template>

<script setup lang="ts">
import TrendBadge from "./TrendBadge.vue";
import type { ScoreTrend } from "../types/stock";

defineProps<{
  title: string;
  score: number;
  reasons: string[];
  description: string;
  trend: ScoreTrend;
}>();
</script>

