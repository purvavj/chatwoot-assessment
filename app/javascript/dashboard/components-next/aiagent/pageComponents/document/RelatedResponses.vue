<script setup>
import { ref, computed, onMounted } from 'vue';
import { useStore, useMapGetter } from 'dashboard/composables/store';
import { useI18n } from 'vue-i18n';
import Spinner from 'dashboard/components-next/spinner/Spinner.vue';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import ResponseCard from '../../topic/ResponseCard.vue';
const props = defineProps({
  aiagentDocument: {
    type: Object,
    required: true,
  },
});
const emit = defineEmits(['close']);
const { t } = useI18n();
const store = useStore();
const dialogRef = ref(null);

const uiFlags = useMapGetter('aiagentResponses/getUIFlags');
const responses = useMapGetter('aiagentResponses/getRecords');
const isFetching = computed(() => uiFlags.value.fetchingList);

const handleClose = () => {
  emit('close');
};

onMounted(() => {
  store.dispatch('aiagentResponses/get', {
    topicId: props.aiagentDocument.topic.id,
    documentId: props.aiagentDocument.id,
  });
});
defineExpose({ dialogRef });
</script>

<template>
  <Dialog
    ref="dialogRef"
    type="edit"
    :title="t('AI_AGENT.DOCUMENTS.RELATED_RESPONSES.TITLE')"
    :description="t('AI_AGENT.DOCUMENTS.RELATED_RESPONSES.DESCRIPTION')"
    :show-cancel-button="false"
    :show-confirm-button="false"
    overflow-y-auto
    width="3xl"
    @close="handleClose"
  >
    <div
      v-if="isFetching"
      class="flex items-center justify-center py-10 text-n-slate-11"
    >
      <Spinner />
    </div>
    <div v-else class="flex flex-col gap-3 min-h-48">
      <ResponseCard
        v-for="response in responses"
        :id="response.id"
        :key="response.id"
        :question="response.question"
        :status="response.status"
        :answer="response.answer"
        :topic="response.topic"
        :created-at="response.created_at"
        :updated-at="response.updated_at"
        compact
      />
    </div>
  </Dialog>
</template>
