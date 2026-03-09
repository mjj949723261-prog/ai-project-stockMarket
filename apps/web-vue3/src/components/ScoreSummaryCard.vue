<template>
  <section class="summary-card">
    <div class="row">
      <div>
        <p class="code">{{ code }}</p>
        <h2 style="margin: 4px 0 0">{{ name }}</h2>
      </div>
      <div class="score-big">{{ totalScore }}</div>
    </div>
    <p>{{ verdict }}</p>
    <p class="warn">风险提示：{{ riskWarning }}</p>
  </section>
</template>

<script setup lang="ts">
defineProps<{
  code: string;
  name: string;
  totalScore: number;
  verdict: string;
  riskWarning: string;
}>();
</script>

