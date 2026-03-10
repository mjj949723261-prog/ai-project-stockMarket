<template>
  <section class="summary-card">
    <div class="row">
      <div>
        <p class="code">{{ code }}</p>
        <h2 style="margin: 4px 0 0">{{ name }}</h2>
        <p class="muted summary-comment">{{ summaryComment }}</p>
      </div>
      <div class="summary-score">
        <div class="score-big">{{ totalScore }}</div>
        <div class="price-stack">
          <strong>{{ latestPrice.toFixed(2) }}</strong>
          <span :class="['change-text', changePercent >= 0 ? 'positive' : 'negative']">
            {{ changePercent >= 0 ? "+" : "" }}{{ changePercent.toFixed(2) }}%
          </span>
        </div>
      </div>
    </div>
    <div class="summary-meta">
      <slot name="rating" />
      <p class="chip">{{ verdict }}</p>
    </div>
    <p class="warn">风险提示：{{ riskWarning }}</p>
  </section>
</template>

<script setup lang="ts">
defineProps<{
  code: string;
  name: string;
  totalScore: number;
  latestPrice: number;
  changePercent: number;
  summaryComment: string;
  verdict: string;
  riskWarning: string;
}>();
</script>
