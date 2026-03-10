<template>
  <div class="app-shell">
    <main class="page-body">
      <RouterView />
    </main>

    <nav class="bottom-nav">
      <RouterLink to="/">首页</RouterLink>
      <RouterLink to="/hot">热门</RouterLink>
      <RouterLink to="/watchlist">自选</RouterLink>
    </nav>
  </div>
</template>

<script setup lang="ts">
import { RouterLink, RouterView } from "vue-router";
</script>
