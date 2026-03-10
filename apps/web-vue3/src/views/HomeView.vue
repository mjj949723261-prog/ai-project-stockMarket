<template>
  <section class="home-layout">
    <div class="search-stage">
      <div class="panel search-hero-panel">
        <p class="eyebrow">Search First</p>
        <h2 class="hero-title">先搜股票，再看方向和证据</h2>
        <p class="subtitle">把最近搜索、热门板块和高价值资讯放在同一页，减少来回跳转。</p>
        <SearchBar :model-value="query" @update:model-value="setQuery" />
      </div>

      <div class="panel">
        <div class="row">
          <h2 class="section-title" style="margin: 0">搜索记录</h2>
          <span class="muted">{{ searchHistory.length }} 条</span>
        </div>
        <div class="chip-row">
          <button
            v-for="item in searchHistory"
            :key="item"
            class="chip chip-button"
            type="button"
            @click="applySearchHistory(item)"
          >
            {{ item }}
          </button>
        </div>
      </div>
    </div>

    <div class="home-main-grid">
      <div class="panel">
        <div class="row">
          <h2 class="section-title" style="margin: 0">搜索结果</h2>
          <span class="muted">{{ filteredStocks.length }} 只</span>
        </div>
        <p v-if="searchError" class="warn">{{ searchError }}</p>
        <p v-else-if="isSearching" class="muted">正在拉取实时数据...</p>
        <div class="stock-list">
          <StockListItem v-for="stock in filteredStocks" :key="stock.code" :stock="stock" />
        </div>
      </div>

      <div class="grid">
        <div class="panel">
          <div class="row">
            <h2 class="section-title" style="margin: 0">热门板块概念</h2>
            <span class="muted">方向先行</span>
          </div>
          <div class="sector-card-grid">
            <HotSectorCard v-for="sector in hotSectorCards" :key="sector.id" :sector="sector" />
          </div>
        </div>

        <div class="panel">
          <div class="row">
            <h2 class="section-title" style="margin: 0">热门资讯入口</h2>
            <span class="muted">先看高价值事件</span>
          </div>
          <div class="news-entry-list">
            <RouterLink
              v-for="item in curatedNews"
              :key="item.id"
              class="news-entry-card"
              :to="`/news/${item.id}`"
            >
              <div class="row">
                <span class="insight-tag">{{ item.region === "global" ? "国际" : "国内" }}</span>
                <span :class="['signal-chip', item.impact]">{{ item.impact === "positive" ? "利好" : item.impact === "negative" ? "利空" : "中性" }}</span>
              </div>
              <h3 class="news-entry-title">{{ item.title }}</h3>
              <p class="muted">{{ item.summary }}</p>
              <div class="meta-row">
                <span>{{ item.source }}</span>
                <span>{{ item.stockName }}</span>
              </div>
            </RouterLink>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { RouterLink } from "vue-router";
import HotSectorCard from "../components/HotSectorCard.vue";
import SearchBar from "../components/SearchBar.vue";
import StockListItem from "../components/StockListItem.vue";
import { useStocks } from "../composables/useStocks";

const {
  query,
  filteredStocks,
  curatedNews,
  hotSectorCards,
  isSearching,
  searchError,
  searchHistory,
  setQuery,
  applySearchHistory
} = useStocks();
</script>
