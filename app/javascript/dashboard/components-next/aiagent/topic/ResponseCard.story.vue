<script setup>
import ResponseCard from './ResponseCard.vue';
import { responsesList } from 'dashboard/components-next/aiagent/pageComponents/emptyStates/aiagentEmptyStateContent.js';
</script>

<template>
  <Story
    title="AIAgent/Topic/ResponseCard"
    :layout="{ type: 'grid', width: '700px' }"
  >
    <Variant title="Article Card">
      <div
        v-for="(response, index) in responsesList"
        :key="index"
        class="px-20 py-4 bg-white dark:bg-slate-900"
      >
        <ResponseCard
          :id="response.id"
          :question="response.question"
          :answer="response.answer"
          :status="response.status"
          :topic="response.topic"
          :created-at="response.created_at"
        />
      </div>
    </Variant>
  </Story>
</template>
