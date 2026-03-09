<template>
  <section class="grid">
    <div class="panel">
      <h2 class="section-title">搜索股票</h2>
      <SearchBar :model-value="query" @update:model-value="setQuery" />
    </div>

    <div class="panel">
      <div class="row">
        <h2 class="section-title" style="margin: 0">候选股票</h2>
        <span class="muted">{{ filteredStocks.length }} 只</span>
      </div>
      <div class="stock-list">
        <StockListItem v-for="stock in filteredStocks" :key="stock.code" :stock="stock" />
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import SearchBar from "../components/SearchBar.vue";
import StockListItem from "../components/StockListItem.vue";
import { useStocks } from "../composables/useStocks";

const { query, filteredStocks, setQuery } = useStocks();
</script>

