<template>
  <div class="search-shell">
    <input
      class="search-input"
      :value="modelValue"
      placeholder="搜索股票代码或名称"
      @input="emit('update:modelValue', ($event.target as HTMLInputElement).value)"
    />
    <div class="chip-row">
      <span class="chip">总分 + 四维分项分</span>
      <span class="chip">风险提示</span>
      <span class="chip">评分依据</span>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  modelValue: string;
}>();

const emit = defineEmits<{
  "update:modelValue": [value: string];
}>();
</script>

