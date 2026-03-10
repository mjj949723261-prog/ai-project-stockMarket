<template>
  <section class="panel evaluation-panel">
    <div class="row" style="align-items: flex-start">
      <div>
        <h3 class="section-title" style="margin-bottom: 6px">综合评价</h3>
        <p>{{ summaryComment }}</p>
      </div>
      <div class="advice-box">{{ advice }}</div>
    </div>

    <div class="evaluation-grid">
      <div>
        <h4 class="mini-title">主要加分项</h4>
        <ul class="reason-list compact-list">
          <li v-for="item in highlightPoints" :key="item">{{ item }}</li>
        </ul>
      </div>
      <div>
        <h4 class="mini-title">主要扣分项</h4>
        <ul class="reason-list compact-list">
          <li v-for="item in riskPoints" :key="item">{{ item }}</li>
        </ul>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
defineProps<{
  summaryComment: string;
  advice: string;
  highlightPoints: string[];
  riskPoints: string[];
}>();
</script>
