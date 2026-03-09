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

    <div class="panel">
      <div class="row">
        <h2 class="section-title" style="margin: 0">最近评分变动</h2>
        <span class="muted">帮助你先筛再看</span>
      </div>
      <div class="stock-list">
        <div v-for="stock in filteredStocks.slice(0, 3)" :key="`${stock.code}-delta`" class="stock-item">
          <div class="row">
            <strong>{{ stock.name }}</strong>
            <span class="score-pill">{{ scoreDelta(stock.code) > 0 ? "+" : "" }}{{ scoreDelta(stock.code) }}</span>
          </div>
          <p class="muted">最近一次变化：{{ stock.scoreHistory[stock.scoreHistory.length - 2] }} -> {{ stock.scoreHistory[stock.scoreHistory.length - 1] }}</p>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import SearchBar from "../components/SearchBar.vue";
import StockListItem from "../components/StockListItem.vue";
import { useStocks } from "../composables/useStocks";

const { query, filteredStocks, setQuery, scoreDelta } = useStocks();
</script>
