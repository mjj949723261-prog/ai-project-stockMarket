<template>
  <div class="app-shell">
    <header class="hero">
      <p class="eyebrow">A 股研究入口</p>
      <h1>Signal Deck</h1>
      <p class="subtitle">
        把股票、板块和资讯证据放进同一套研究流程，而不是继续被传统资讯页拖慢判断。
      </p>
    </header>

    <main class="page-body">
      <RouterView />
    </main>

    <nav class="bottom-nav">
      <RouterLink to="/">首页</RouterLink>
      <RouterLink to="/watchlist">自选</RouterLink>
    </nav>
  </div>
</template>

<script setup lang="ts">
import { RouterLink, RouterView } from "vue-router";
</script>
