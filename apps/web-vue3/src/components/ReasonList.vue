<template>
  <section class="panel">
    <h3 class="section-title">{{ title }}</h3>
    <ul class="reason-list" style="margin: 0; padding-left: 18px">
      <li v-for="reason in reasons" :key="reason">{{ reason }}</li>
    </ul>
  </section>
</template>

<script setup lang="ts">
defineProps<{
  title: string;
  reasons: string[];
}>();
</script>

