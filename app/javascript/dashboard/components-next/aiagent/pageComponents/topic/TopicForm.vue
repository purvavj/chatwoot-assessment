<script setup>
import { reactive, computed, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useVuelidate } from '@vuelidate/core';
import { required, minLength } from '@vuelidate/validators';
import { useMapGetter } from 'dashboard/composables/store';

import Input from 'dashboard/components-next/input/Input.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import Editor from 'dashboard/components-next/Editor/Editor.vue';

const props = defineProps({
  mode: {
    type: String,
    required: true,
    validator: value => ['edit', 'create'].includes(value),
  },
  topic: {
    type: Object,
    default: () => ({}),
  },
});

const emit = defineEmits(['submit', 'cancel']);

const { t } = useI18n();

const formState = {
  uiFlags: useMapGetter('aiagentTopics/getUIFlags'),
};

const initialState = {
  name: '',
  description: '',
  productName: '',
  featureFaq: false,
  featureMemory: false,
};

const state = reactive({ ...initialState });

const validationRules = {
  name: { required, minLength: minLength(1) },
  description: { required, minLength: minLength(1) },
  productName: { required, minLength: minLength(1) },
};

const v$ = useVuelidate(validationRules, state);

const isLoading = computed(() => formState.uiFlags.value.creatingItem);

const getErrorMessage = (field, errorKey) => {
  return v$.value[field].$error
    ? t(`AI_AGENT.TOPICS.FORM.${errorKey}.ERROR`)
    : '';
};

const formErrors = computed(() => ({
  name: getErrorMessage('name', 'NAME'),
  description: getErrorMessage('description', 'DESCRIPTION'),
  productName: getErrorMessage('productName', 'PRODUCT_NAME'),
}));

const handleCancel = () => emit('cancel');

const prepareTopicDetails = () => ({
  name: state.name,
  description: state.description,
  config: {
    product_name: state.productName,
    feature_faq: state.featureFaq,
    feature_memory: state.featureMemory,
  },
});

const handleSubmit = async () => {
  const isFormValid = await v$.value.$validate();
  if (!isFormValid) {
    return;
  }

  emit('submit', prepareTopicDetails());
};

const updateStateFromTopic = topic => {
  if (!topic) return;

  const { name, description, config } = topic;

  Object.assign(state, {
    name,
    description,
    productName: config.product_name,
    featureFaq: config.feature_faq || false,
    featureMemory: config.feature_memory || false,
  });
};

watch(
  () => props.topic,
  newTopic => {
    if (props.mode === 'edit' && newTopic) {
      updateStateFromTopic(newTopic);
    }
  },
  { immediate: true }
);
</script>

<template>
  <form class="flex flex-col gap-4" @submit.prevent="handleSubmit">
    <Input
      v-model="state.name"
      :label="t('AI_AGENT.TOPICS.FORM.NAME.LABEL')"
      :placeholder="t('AI_AGENT.TOPICS.FORM.NAME.PLACEHOLDER')"
      :message="formErrors.name"
      :message-type="formErrors.name ? 'error' : 'info'"
    />

    <Editor
      v-model="state.description"
      :label="t('AI_AGENT.TOPICS.FORM.DESCRIPTION.LABEL')"
      :placeholder="t('AI_AGENT.TOPICS.FORM.DESCRIPTION.PLACEHOLDER')"
      :message="formErrors.description"
      :message-type="formErrors.description ? 'error' : 'info'"
    />

    <Input
      v-model="state.productName"
      :label="t('AI_AGENT.TOPICS.FORM.PRODUCT_NAME.LABEL')"
      :placeholder="t('AI_AGENT.TOPICS.FORM.PRODUCT_NAME.PLACEHOLDER')"
      :message="formErrors.productName"
      :message-type="formErrors.productName ? 'error' : 'info'"
    />

    <fieldset class="flex flex-col gap-2.5">
      <legend class="mb-3 text-sm font-medium text-n-slate-12">
        {{ t('AI_AGENT.TOPICS.FORM.FEATURES.TITLE') }}
      </legend>

      <label class="flex items-center gap-2">
        <input v-model="state.featureFaq" type="checkbox" />
        <span class="text-sm font-medium text-n-slate-12">
          {{ t('AI_AGENT.TOPICS.FORM.FEATURES.ALLOW_CONVERSATION_FAQS') }}
        </span>
      </label>

      <label class="flex items-center gap-2">
        <input v-model="state.featureMemory" type="checkbox" />
        <span class="text-sm font-medium text-n-slate-12">
          {{ t('AI_AGENT.TOPICS.FORM.FEATURES.ALLOW_MEMORIES') }}
        </span>
      </label>
    </fieldset>

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
