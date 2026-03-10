<template>
  <section class="grid">
    <div class="panel search-hero-panel">
      <div class="row home-top-row">
        <div>
          <p class="eyebrow">Search</p>
          <h2 class="section-display">搜索 + 热门资讯</h2>
        </div>
        <span class="chip">今日研究入口</span>
      </div>
      <p class="subtitle">先搜股票，再直接进入今天最值得看的资讯和证据。</p>
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

    <div v-if="query.trim()" class="panel">
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

    <div class="panel">
      <div class="row">
        <h2 class="section-title" style="margin: 0">热门资讯</h2>
        <RouterLink class="chip" to="/hot">查看热门页</RouterLink>
      </div>
      <div class="news-entry-list">
        <article
          v-for="item in curatedNews"
          :key="item.id"
          class="news-entry-card"
          @click="openNews(item.id)"
        >
          <div class="row">
            <span class="insight-tag">{{ item.region === "global" ? "国际" : "国内" }}</span>
            <span :class="['signal-chip', item.impact]">{{ item.impact === "positive" ? "利好" : item.impact === "negative" ? "利空" : "中性" }}</span>
          </div>
          <h3 class="news-entry-title">{{ item.title }}</h3>
          <p class="muted">{{ item.summary }}</p>
          <div class="meta-row">
            <span>{{ item.source }}</span>
            <span v-if="item.stockName">{{ item.stockName }}</span>
            <span v-else class="chip-row compact-chip-row">
              <button
                v-for="sector in item.sectors"
                :key="sector"
                class="chip chip-button"
                type="button"
                @click.stop="openSector(sector)"
              >
                {{ sector }}
              </button>
            </span>
          </div>
        </article>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { RouterLink, useRouter } from "vue-router";
import SearchBar from "../components/SearchBar.vue";
import StockListItem from "../components/StockListItem.vue";
import { useStocks } from "../composables/useStocks";

const {
  query,
  filteredStocks,
  curatedNews,
  isSearching,
  searchError,
  searchHistory,
  findSectorIdByName,
  setQuery,
  applySearchHistory
} = useStocks();
const router = useRouter();

function openNews(id: string) {
  void router.push(`/news/${id}`);
}

function openSector(name: string) {
  const id = findSectorIdByName(name);
  if (!id) return;
  void router.push(`/sectors/${id}`);
}
</script>
