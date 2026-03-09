<template>
  <RouterLink class="stock-item" :to="`/stocks/${stock.code}`">
    <div class="row">
      <div>
        <strong>{{ stock.name }}</strong>
        <div class="code">{{ stock.code }}</div>
      </div>
      <span class="score-pill">{{ stock.totalScore }}</span>
    </div>

    <div class="row">
      <span class="muted">{{ stock.verdict }}</span>
      <div class="chip-row">
        <span class="chip">5日 {{ stock.scoreHistory[stock.scoreHistory.length - 1] - stock.scoreHistory[0] > 0 ? "+" : "" }}{{ stock.scoreHistory[stock.scoreHistory.length - 1] - stock.scoreHistory[0] }}</span>
        <TrendBadge :trend="stock.scoreTrend" />
      </div>
    </div>
  </RouterLink>
</template>

<script setup lang="ts">
import { RouterLink } from "vue-router";
import TrendBadge from "./TrendBadge.vue";
import type { StockAnalysis } from "../types/stock";

defineProps<{
  stock: StockAnalysis;
}>();
</script>
