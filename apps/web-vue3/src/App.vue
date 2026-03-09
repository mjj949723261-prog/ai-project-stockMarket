<template>
  <div class="app-shell">
    <header class="hero">
      <p class="eyebrow">A 股单股票综合评分助手</p>
      <h1>股市资讯 App</h1>
      <p class="subtitle">
        用统一的评分结构看一只股票是否值得继续研究，而不是被资讯流淹没。
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

