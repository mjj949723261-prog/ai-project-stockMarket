<template>
  <section class="panel kline-card">
    <div class="row">
      <div>
        <h3 class="section-title" style="margin-bottom: 6px">K线与关键走势</h3>
        <p class="muted">近 {{ candles.length }} 个交易日的简化 K 线，用来判断当前强弱和节奏。</p>
      </div>
      <div class="kline-price">
        <strong>{{ latestPrice.toFixed(2) }}</strong>
        <span :class="['change-text', changePercent >= 0 ? 'positive' : 'negative']">
          {{ changePercent >= 0 ? "+" : "" }}{{ changePercent.toFixed(2) }}%
        </span>
      </div>
    </div>

    <svg v-if="candles.length" viewBox="0 0 100 64" class="kline-chart" role="img" aria-label="K线走势">
      <g v-for="(candle, index) in normalizedCandles" :key="`${candle.date}-${index}`">
        <line
          :x1="candle.x"
          :x2="candle.x"
          :y1="candle.high"
          :y2="candle.low"
          :class="['kline-wick', candle.rising ? 'positive' : 'negative']"
        />
        <rect
          :x="candle.x - 3"
          :y="Math.min(candle.open, candle.close)"
          width="6"
          :height="Math.max(Math.abs(candle.open - candle.close), 1.4)"
          rx="1.5"
          :class="['kline-body', candle.rising ? 'positive' : 'negative']"
        />
      </g>
    </svg>

    <div class="chip-row">
      <span class="chip">最高 {{ highest.toFixed(2) }}</span>
      <span class="chip">最低 {{ lowest.toFixed(2) }}</span>
      <span class="chip">收盘趋势 {{ trendText }}</span>
    </div>
  </section>
</template>

<script setup lang="ts">
import { computed } from "vue";
import type { CandlePoint, ScoreTrend } from "../types/stock";

const props = defineProps<{
  candles: CandlePoint[];
  latestPrice: number;
  changePercent: number;
  trend: ScoreTrend;
}>();

const highest = computed(() => Math.max(...props.candles.map((item) => item.high)));
const lowest = computed(() => Math.min(...props.candles.map((item) => item.low)));

const trendText = computed(() => {
  if (props.trend === "up") return "改善中";
  if (props.trend === "down") return "转弱";
  return "震荡";
});

const normalizedCandles = computed(() => {
  const high = highest.value;
  const low = lowest.value;
  const range = high - low || 1;

  return props.candles.map((candle, index) => {
    const x = 8 + index * (84 / Math.max(props.candles.length - 1, 1));
    const mapY = (value: number) => 56 - ((value - low) / range) * 44;
    return {
      ...candle,
      x,
      open: mapY(candle.open),
      close: mapY(candle.close),
      high: mapY(candle.high),
      low: mapY(candle.low),
      rising: candle.close >= candle.open,
    };
  });
});
</script>
