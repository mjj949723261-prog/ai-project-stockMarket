<template>
  <section class="grid">
    <div class="panel">
      <div class="row">
        <h2 class="section-title" style="margin: 0">自选股票</h2>
        <span class="muted">{{ watchlistStocks.length }} 只</span>
      </div>
      <div v-if="watchlistStocks.length" class="stock-list">
        <StockListItem v-for="stock in watchlistStocks" :key="stock.code" :stock="stock" />
      </div>
      <p v-else class="muted">还没有加入自选，先去首页挑一只股票。</p>
    </div>
  </section>
</template>

<script setup lang="ts">
import StockListItem from "../components/StockListItem.vue";
import { useStocks } from "../composables/useStocks";

const { watchlistStocks } = useStocks();
</script>

