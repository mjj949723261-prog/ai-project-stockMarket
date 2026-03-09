<template>
  <RouterLink class="stock-item" :to="`/stocks/${stock.code}`">
    <div class="row">
      <div>
        <strong>{{ stock.name }}</strong>
        <div class="code">{{ stock.code }}</div>
      </div>
      <span class="score-pill">{{ stock.totalScore ?? "--" }}</span>
    </div>

    <div class="row">
      <span class="muted">{{ stock.verdict ?? "点击查看实时分析" }}</span>
      <div class="chip-row">
        <span v-if="stock.scoreHistory" class="chip">5日 {{ stock.scoreHistory[stock.scoreHistory.length - 1] - stock.scoreHistory[0] > 0 ? "+" : "" }}{{ stock.scoreHistory[stock.scoreHistory.length - 1] - stock.scoreHistory[0] }}</span>
        <TrendBadge :trend="stock.scoreTrend ?? 'flat'" />
      </div>
    </div>
  </RouterLink>
</template>

<script setup lang="ts">
import { RouterLink } from "vue-router";
import TrendBadge from "./TrendBadge.vue";
import type { StockCard } from "../types/stock";

defineProps<{
  stock: StockCard;
}>();
</script>
