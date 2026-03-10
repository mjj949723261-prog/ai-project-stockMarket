<template>
  <section class="panel">
    <div class="row">
      <div>
        <h3 class="section-title" style="margin-bottom: 6px">资讯证据</h3>
        <p class="muted">按判断价值排序，而不是单纯堆新闻。</p>
      </div>
      <span class="chip">公司 / 行业 / 宏观</span>
    </div>

    <div class="insight-list">
      <RouterLink
        v-for="item in items"
        :key="`${item.category}-${item.title}`"
        class="insight-card news-card-link"
        :to="`/news/${item.id}`"
      >
        <div class="row" style="align-items: flex-start">
          <div>
            <div class="signal-row">
              <span class="insight-tag">{{ categoryLabel(item.category) }}</span>
              <strong>{{ item.title }}</strong>
            </div>
            <p class="muted">{{ item.summary }}</p>
          </div>
          <span :class="['signal-chip', item.impact]">{{ impactText(item.impact) }}</span>
        </div>

        <div class="chip-row">
          <span v-for="sector in item.sectors" :key="sector" class="chip">{{ sector }}</span>
          <span class="chip">{{ item.region === "global" ? "国际" : "国内" }}</span>
          <span class="chip">{{ item.scoreEffect }}</span>
        </div>

        <div class="meta-row">
          <span>{{ item.source }}</span>
          <span>{{ item.publishedAt }}</span>
        </div>
      </RouterLink>
    </div>
  </section>
</template>

<script setup lang="ts">
import { RouterLink } from "vue-router";
import type { ImpactValue, InsightCategory, InsightItem } from "../types/stock";

defineProps<{
  items: InsightItem[];
}>();

function impactText(value: ImpactValue) {
  if (value === "positive") return "利好";
  if (value === "negative") return "利空";
  return "中性";
}

function categoryLabel(category: InsightCategory) {
  if (category === "company") return "公司";
  if (category === "sector") return "板块";
  return "宏观";
}
</script>
