<template>
  <section v-if="sector" class="grid">
    <div class="panel sector-detail-hero">
      <div class="row">
        <div>
          <p class="eyebrow">Sector Focus</p>
          <h1 class="news-detail-title">{{ sector.name }}</h1>
        </div>
        <span :class="['sector-heat', sector.heat]">{{ heatText }}</span>
      </div>
      <p class="sector-status">{{ sector.status }}</p>
      <p class="news-detail-summary">{{ sector.summary }}</p>
      <div class="chip-row">
        <span v-for="item in sector.highlights" :key="item" class="chip">{{ item }}</span>
      </div>
    </div>

    <div class="panel">
      <div class="row">
        <h2 class="section-title" style="margin: 0">相关股票</h2>
        <span class="muted">{{ sectorStocks.length }} 只</span>
      </div>
      <div class="stock-list">
        <StockListItem v-for="stock in sectorStocks" :key="stock.code" :stock="stock" />
      </div>
    </div>
  </section>

  <section v-else class="panel">
    <h2 class="section-title">未找到板块</h2>
    <p class="muted">请返回热门页重新选择板块。</p>
  </section>
</template>

<script setup lang="ts">
import { computed, onMounted } from "vue";
import { useRoute } from "vue-router";
import StockListItem from "../components/StockListItem.vue";
import { useStocks } from "../composables/useStocks";

const route = useRoute();
const { getSectorById, getSectorStocks, ensureAnalysis } = useStocks();

const sector = computed(() => getSectorById(String(route.params.id ?? "")));
const sectorStocks = computed(() => getSectorStocks(String(route.params.id ?? "")));

const heatText = computed(() => {
  if (!sector.value) return "";
  if (sector.value.heat === "high") return "高关注";
  if (sector.value.heat === "warming") return "升温中";
  return "分化中";
});

onMounted(() => {
  sectorStocks.value.forEach((stock) => {
    void ensureAnalysis(stock.code);
  });
});
</script>
