<template>
  <section class="grid">
    <div class="panel">
      <div class="row">
        <h2 class="section-title" style="margin: 0">自选股票</h2>
        <span class="muted">{{ watchlistStocks.length }} 只</span>
      </div>
      <div v-if="watchlistStocks.length" class="stock-list">
        <div v-for="stock in watchlistStocks" :key="stock.code" class="watchlist-row">
          <StockListItem :stock="stock" />
          <button class="chip chip-button" type="button" @click="toggleWatchlist(stock.code)">
            移除自选
          </button>
        </div>
      </div>
      <p v-else class="muted">还没有加入自选，先去首页挑一只股票。</p>
    </div>

    <div v-if="watchlistStocks.length" class="panel">
      <h2 class="section-title">自选对比</h2>
      <div class="compare-table">
        <div class="compare-row compare-head">
          <span>股票</span>
          <span>总分</span>
          <span>基本面</span>
          <span>消息面</span>
          <span>技术面</span>
          <span>情绪面</span>
        </div>
        <div v-for="stock in comparableStocks" :key="`${stock.code}-compare`" class="compare-row">
          <span>{{ stock.name }}</span>
          <span>{{ stock.totalScore ?? "--" }}</span>
          <span>{{ stock.fundamentalsScore ?? "--" }}</span>
          <span>{{ stock.newsScore ?? "--" }}</span>
          <span>{{ stock.technicalsScore ?? "--" }}</span>
          <span>{{ stock.sentimentScore ?? "--" }}</span>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { computed, onMounted } from "vue";
import StockListItem from "../components/StockListItem.vue";
import { useStocks } from "../composables/useStocks";

const { watchlistStocks, ensureAnalysis, toggleWatchlist } = useStocks();
const comparableStocks = computed(() => watchlistStocks.value.filter((stock) => stock.totalScore));

onMounted(() => {
  watchlistStocks.value.forEach((stock) => {
    void ensureAnalysis(stock.code);
  });
});
</script>
