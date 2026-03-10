<template>
  <section class="panel">
    <div class="row">
      <div>
        <h3 class="section-title" style="margin-bottom: 6px">板块影响</h3>
        <p class="muted">告诉你当前判断主要被哪些板块驱动。</p>
      </div>
      <span class="chip">{{ impacts.length }} 个重点板块</span>
    </div>

    <div class="sector-grid">
      <article v-for="impact in impacts" :key="impact.sector" class="sector-card">
        <div class="row">
          <strong>{{ impact.sector }}</strong>
          <span :class="['signal-chip', impact.impact]">{{ impactText(impact.impact) }}</span>
        </div>
        <p class="muted">{{ impact.reason }}</p>
      </article>
    </div>
  </section>
</template>

<script setup lang="ts">
import type { ImpactValue, SectorImpactItem } from "../types/stock";

defineProps<{
  impacts: SectorImpactItem[];
}>();

function impactText(value: ImpactValue) {
  if (value === "positive") return "偏利好";
  if (value === "negative") return "偏利空";
  return "中性";
}
</script>
