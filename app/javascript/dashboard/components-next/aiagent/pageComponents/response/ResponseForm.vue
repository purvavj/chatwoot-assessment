<script setup>
import { reactive, computed, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useVuelidate } from '@vuelidate/core';
import { required, minLength } from '@vuelidate/validators';
import { useMapGetter } from 'dashboard/composables/store';

import Input from 'dashboard/components-next/input/Input.vue';
import Editor from 'dashboard/components-next/Editor/Editor.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import ComboBox from 'dashboard/components-next/combobox/ComboBox.vue';

const props = defineProps({
  mode: {
    type: String,
    required: true,
    validator: value => ['edit', 'create'].includes(value),
  },
  response: {
    type: Object,
    default: () => ({}),
  },
});
const emit = defineEmits(['submit', 'cancel']);
const { t } = useI18n();

const formState = {
  uiFlags: useMapGetter('aiagentResponses/getUIFlags'),
  topics: useMapGetter('aiagentTopics/getRecords'),
};

const initialState = {
  question: '',
  answer: '',
  topicId: null,
};

const state = reactive({ ...initialState });

const validationRules = {
  question: { required, minLength: minLength(1) },
  answer: { required, minLength: minLength(1) },
  topicId: { required },
};

const topicList = computed(() =>
  formState.topics.value.map(topic => ({
    value: topic.id,
    label: topic.name,
  }))
);

const v$ = useVuelidate(validationRules, state);

const isLoading = computed(() => formState.uiFlags.value.creatingItem);

const getErrorMessage = (field, errorKey) => {
  return v$.value[field].$error
    ? t(`AI_AGENT.RESPONSES.FORM.${errorKey}.ERROR`)
    : '';
};

const formErrors = computed(() => ({
  question: getErrorMessage('question', 'QUESTION'),
  answer: getErrorMessage('answer', 'ANSWER'),
  topicId: getErrorMessage('topicId', 'TOPIC'),
}));

const handleCancel = () => emit('cancel');

const prepareDocumentDetails = () => ({
  question: state.question,
  answer: state.answer,
  topic_id: state.topicId,
});

const handleSubmit = async () => {
  const isFormValid = await v$.value.$validate();
  if (!isFormValid) {
    return;
  }

  emit('submit', prepareDocumentDetails());
};

const updateStateFromResponse = response => {
  if (!response) return;

  const { question, answer, topic } = response;

  Object.assign(state, {
    question,
    answer,
    topicId: topic.id,
  });
};

watch(
  () => props.response,
  newResponse => {
    if (props.mode === 'edit' && newResponse) {
      updateStateFromResponse(newResponse);
    }
  },
  { immediate: true }
);
</script>

<template>
  <form class="flex flex-col gap-4" @submit.prevent="handleSubmit">
    <Input
      v-model="state.question"
      :label="t('AI_AGENT.RESPONSES.FORM.QUESTION.LABEL')"
      :placeholder="t('AI_AGENT.RESPONSES.FORM.QUESTION.PLACEHOLDER')"
      :message="formErrors.question"
      :message-type="formErrors.question ? 'error' : 'info'"
    />

    <Editor
      v-model="state.answer"
      :label="t('AI_AGENT.RESPONSES.FORM.ANSWER.LABEL')"
      :placeholder="t('AI_AGENT.RESPONSES.FORM.ANSWER.PLACEHOLDER')"
      :message="formErrors.answer"
      :max-length="10000"
      :message-type="formErrors.answer ? 'error' : 'info'"
    />

    <div class="flex flex-col gap-1">
      <label for="topic" class="mb-0.5 text-sm font-medium text-n-slate-12">
        {{ t('AI_AGENT.RESPONSES.FORM.TOPIC.LABEL') }}
      </label>
      <ComboBox
        id="topic"
        v-model="state.topicId"
        :options="topicList"
        :has-error="!!formErrors.topicId"
        :placeholder="t('AI_AGENT.RESPONSES.FORM.TOPIC.PLACEHOLDER')"
        class="[&>div>button]:bg-n-alpha-black2 [&>div>button:not(.focused)]:dark:outline-n-weak [&>div>button:not(.focused)]:hover:!outline-n-slate-6"
        :message="formErrors.topicId"
      />
    </div>

    <div class="flex items-center justify-between w-full gap-3">
      <Button
        type="button"
        variant="faded"
        color="slate"
        :label="t('AI_AGENT.FORM.CANCEL')"
        class="w-full bg-n-alpha-2 n-blue-text hover:bg-n-alpha-3"
        @click="handleCancel"
      />
      <Button
        type="submit"
        :label="t(`AI_AGENT.FORM.${mode.toUpperCase()}`)"
        class="w-full"
        :is-loading="isLoading"
        :disabled="isLoading"
      />
    </div>
  </form>
</template>
