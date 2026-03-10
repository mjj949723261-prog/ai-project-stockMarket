<template>
  <section v-if="news" class="news-detail-page">
    <div class="news-detail-hero">
      <div class="news-detail-meta">
        <span class="chip">{{ news.region === "global" ? "国际资讯" : "国内资讯" }}</span>
        <span :class="['signal-chip', news.impact]">{{ impactLabel }}</span>
        <span class="chip">{{ urgencyLabel }}</span>
      </div>
      <h1 class="news-detail-title">{{ news.title }}</h1>
      <p class="news-detail-summary">{{ news.summary }}</p>
      <div class="meta-row">
        <span>{{ news.source }}</span>
        <span>{{ news.publishedAt }}</span>
      </div>
    </div>

    <div class="news-detail-grid">
      <section class="panel">
        <h2 class="section-title">核心摘要</h2>
        <p class="news-detail-body">
          这条资讯当前被系统归类为{{ impactLabel }}，主要影响{{ news.sectors.join("、") || "相关板块" }}。
          它会先修正消息面判断，再决定是否改变短期跟踪节奏。
        </p>
      </section>

      <section class="panel">
        <h2 class="section-title">影响板块</h2>
        <div class="chip-row">
          <component
            :is="sectorLink(sector) ? RouterLink : 'span'"
            v-for="sector in news.sectors"
            :key="sector"
            class="chip chip-button"
            :to="sectorLink(sector) ? `/sectors/${sectorLink(sector)}` : undefined"
          >
            {{ sector }}
          </component>
        </div>
      </section>

      <section class="panel">
        <h2 class="section-title">关联股票</h2>
        <RouterLink v-if="news.stockCode" class="stock-item compact-stock" :to="`/stocks/${news.stockCode}`">
          <div>
            <strong>{{ news.stockName }}</strong>
            <div class="code">{{ news.stockCode }}</div>
          </div>
          <span class="chip">查看个股</span>
        </RouterLink>
        <p v-else class="news-detail-body">当前没有明确关联股票，建议优先从影响板块继续展开。</p>
      </section>

      <section class="panel">
        <h2 class="section-title">评分影响</h2>
        <p class="news-detail-body">{{ news.scoreEffect }}</p>
        <a class="source-link" :href="news.sourceUrl" target="_blank" rel="noreferrer">查看原文</a>
      </section>
    </div>
  </section>

  <section v-else class="panel">
    <h2 class="section-title">未找到资讯</h2>
    <p class="muted">请返回首页或个股详情页重新进入资讯详情。</p>
  </section>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { RouterLink, useRoute } from "vue-router";
import { useStocks } from "../composables/useStocks";

const route = useRoute();
const { getNewsById, findSectorIdByName } = useStocks();
const news = computed(() => getNewsById(String(route.params.id ?? "")));

const impactLabel = computed(() => {
  if (!news.value) return "";
  if (news.value.impact === "positive") return "利好";
  if (news.value.impact === "negative") return "利空";
  return "中性";
});

const urgencyLabel = computed(() => {
  if (!news.value) return "";
  if (news.value.urgency === "high") return "高优先级";
  if (news.value.urgency === "medium") return "重点跟踪";
  return "观察信息";
});

function sectorLink(name: string) {
  return findSectorIdByName(name);
}
</script>
