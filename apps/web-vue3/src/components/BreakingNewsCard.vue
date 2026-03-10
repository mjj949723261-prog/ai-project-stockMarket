<template>
  <article class="breaking-card">
    <div class="row" style="align-items: flex-start">
      <div>
        <div class="signal-row">
          <span :class="['impact-dot', item.impact]"></span>
          <strong>{{ item.title }}</strong>
        </div>
        <p class="muted">{{ item.summary }}</p>
      </div>
      <span :class="['alert-pill', item.level]">{{ levelText }}</span>
    </div>

    <div class="chip-row">
      <span :class="['signal-chip', item.impact]">{{ impactText }}</span>
      <span v-for="sector in item.sectors" :key="sector" class="chip">{{ sector }}</span>
      <span class="chip">{{ item.scoreEffect }}</span>
    </div>

    <div class="meta-row">
      <a class="source-link" :href="item.sourceUrl" target="_blank" rel="noreferrer">
        {{ item.source }}
      </a>
      <span>{{ item.region === "global" ? "国际" : "国内" }}</span>
      <span>{{ item.publishedAt }}</span>
    </div>
  </article>
</template>

<script setup lang="ts">
import { computed } from "vue";
import type { BreakingNewsItem } from "../types/stock";

const props = defineProps<{
  item: BreakingNewsItem;
}>();

const impactText = computed(() => {
  if (props.item.impact === "positive") return "利好";
  if (props.item.impact === "negative") return "利空";
  return "中性";
});

const levelText = computed(() => {
  if (props.item.level === "high") return "红色提示";
  if (props.item.level === "low") return "黄色提示";
  return "橙色提示";
});
</script>
