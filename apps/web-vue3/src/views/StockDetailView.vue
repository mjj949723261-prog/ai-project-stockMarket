<template>
  <section v-if="stock" class="grid">
    <ScoreSummaryCard
      :code="stock.code"
      :name="stock.name"
      :total-score="stock.totalScore"
      :verdict="stock.verdict"
      :risk-warning="stock.riskWarning"
    />

    <div class="dimension-grid">
      <DimensionScoreCard
        title="基本面"
        :score="stock.fundamentalsScore"
        :reasons="stock.fundamentalsReasons"
        description="财务质量与估值安全"
        :trend="stock.scoreTrend"
      />
      <DimensionScoreCard
        title="消息面"
        :score="stock.newsScore"
        :reasons="stock.newsReasons"
        description="公告与行业事件"
        :trend="stock.scoreTrend"
      />
      <DimensionScoreCard
        title="技术面"
        :score="stock.technicalsScore"
        :reasons="stock.technicalsReasons"
        description="趋势与量价结构"
        :trend="stock.scoreTrend"
      />
      <DimensionScoreCard
        title="情绪面"
        :score="stock.sentimentScore"
        :reasons="stock.sentimentReasons"
        description="市场关注度与热度"
        :trend="stock.scoreTrend"
      />
    </div>

    <ScoreHistoryStrip :history="stock.scoreHistory" />

    <div class="panel">
      <div class="row">
        <h2 class="section-title" style="margin: 0">操作</h2>
        <button class="chip" type="button" @click="toggleWatchlist(stock.code)">
          {{ isWatched(stock.code) ? "移出自选" : "加入自选" }}
        </button>
      </div>
      <p class="muted">当前状态：{{ isWatched(stock.code) ? "已加入自选" : "未加入自选" }}</p>
    </div>

    <ReasonList title="详细依据：基本面" :reasons="stock.fundamentalsReasons" />
    <ReasonList title="详细依据：消息面" :reasons="stock.newsReasons" />
    <ReasonList title="详细依据：技术面" :reasons="stock.technicalsReasons" />
    <ReasonList title="详细依据：情绪面" :reasons="stock.sentimentReasons" />
  </section>

  <section v-else class="panel">
    <h2 class="section-title">未找到股票</h2>
    <p class="muted">请返回首页重新搜索股票代码或名称。</p>
  </section>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { useRoute } from "vue-router";
import DimensionScoreCard from "../components/DimensionScoreCard.vue";
import ReasonList from "../components/ReasonList.vue";
import ScoreSummaryCard from "../components/ScoreSummaryCard.vue";
import ScoreHistoryStrip from "../components/ScoreHistoryStrip.vue";
import { useStocks } from "../composables/useStocks";

const route = useRoute();
const { findStock, isWatched, toggleWatchlist } = useStocks();

// 详情页只从统一 mock 数据中取目标股票，避免页面自己维护独立状态。
const stock = computed(() => findStock(String(route.params.code ?? "")));
</script>
