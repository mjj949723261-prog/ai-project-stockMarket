<template>
  <RouterLink class="hot-sector-card sector-card-link" :to="`/sectors/${sector.id}`">
    <div class="row">
      <div>
        <p class="eyebrow sector-eyebrow">热门板块</p>
        <h3 class="sector-title">{{ sector.name }}</h3>
      </div>
      <span :class="['sector-heat', sector.heat]">{{ heatText }}</span>
    </div>

    <p class="sector-status">{{ sector.status }}</p>

    <div class="sector-stocks">
      <RouterLink
        v-for="stock in sector.stocks"
        :key="stock.code"
        class="sector-stock-link"
        :to="`/stocks/${stock.code}`"
        @click.stop
      >
        <strong>{{ stock.name }}</strong>
        <span class="chip">{{ stock.tag }}</span>
      </RouterLink>
    </div>
  </RouterLink>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { RouterLink } from "vue-router";
import type { HotSector } from "../types/stock";

const props = defineProps<{
  sector: HotSector;
}>();

const heatText = computed(() => {
  if (props.sector.heat === "high") return "高关注";
  if (props.sector.heat === "warming") return "升温中";
  return "分化中";
});
</script>
