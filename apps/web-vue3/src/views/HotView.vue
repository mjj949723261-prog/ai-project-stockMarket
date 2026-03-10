<template>
  <section class="grid">
    <div class="panel page-heading">
      <div>
        <p class="eyebrow">Hot List</p>
        <h2 class="section-display">热门方向与热门股票</h2>
      </div>
      <p class="subtitle">先看方向，再看最值得点进去的股票。</p>
    </div>

    <div class="panel">
      <div class="row">
        <h2 class="section-title" style="margin: 0">热门板块</h2>
        <span class="muted">{{ hotSectorCards.length }} 个方向</span>
      </div>
      <div class="hot-sector-list">
        <HotSectorCard v-for="sector in hotSectorCards" :key="sector.id" :sector="sector" />
      </div>
    </div>

    <div class="panel">
      <div class="row">
        <h2 class="section-title" style="margin: 0">热门股票</h2>
        <span class="muted">按当前关注度聚合</span>
      </div>
      <div class="stock-list">
        <StockListItem v-for="stock in hotStocks" :key="stock.code" :stock="stock" />
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { onMounted } from "vue";
import HotSectorCard from "../components/HotSectorCard.vue";
import StockListItem from "../components/StockListItem.vue";
import { useStocks } from "../composables/useStocks";

const { hotSectorCards, hotStocks, ensureAnalysis } = useStocks();

onMounted(() => {
  hotStocks.value.forEach((stock) => {
    void ensureAnalysis(stock.code);
  });
});
</script>
