<script setup>
import { ref } from 'vue';
import { useStore } from 'dashboard/composables/store';
import { useAlert } from 'dashboard/composables';
import { useI18n } from 'vue-i18n';

import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import ConnectInboxForm from './ConnectInboxForm.vue';

defineProps({
  topicId: {
    type: Number,
    required: true,
  },
});
const emit = defineEmits(['close']);
const { t } = useI18n();
const store = useStore();

const dialogRef = ref(null);
const connectForm = ref(null);

const i18nKey = 'AI_AGENT.INBOXES.CREATE';

const handleSubmit = async payload => {
  try {
    await store.dispatch('aiagentInboxes/create', payload);
    useAlert(t(`${i18nKey}.SUCCESS_MESSAGE`));
    dialogRef.value.close();
  } catch (error) {
    const errorMessage = error?.message || t(`${i18nKey}.ERROR_MESSAGE`);
    useAlert(errorMessage);
  }
};

const handleClose = () => {
  emit('close');
};

const handleCancel = () => {
  dialogRef.value.close();
};

defineExpose({ dialogRef });
</script>

<template>
  <Dialog
    ref="dialogRef"
    type="create"
    :title="$t(`${i18nKey}.TITLE`)"
    :description="$t('AI_AGENT.INBOXES.FORM_DESCRIPTION')"
    :show-cancel-button="false"
    :show-confirm-button="false"
    @close="handleClose"
  >
    <ConnectInboxForm
      ref="connectForm"
      :topic-id="topicId"
      @submit="handleSubmit"
      @cancel="handleCancel"
    />
    <template #footer />
  </Dialog>
</template>
