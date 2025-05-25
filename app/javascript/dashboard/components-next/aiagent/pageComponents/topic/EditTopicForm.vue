<script setup>
import { reactive, computed, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useVuelidate } from '@vuelidate/core';
import { required, minLength } from '@vuelidate/validators';
import { useMapGetter } from 'dashboard/composables/store';

import Input from 'dashboard/components-next/input/Input.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import Editor from 'dashboard/components-next/Editor/Editor.vue';
import Accordion from 'dashboard/components-next/Accordion/Accordion.vue';

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

const emit = defineEmits(['submit']);

const { t } = useI18n();

const formState = {
  uiFlags: useMapGetter('aiagentTopics/getUIFlags'),
};

const initialState = {
  name: '',
  description: '',
  productName: '',
  welcomeMessage: '',
  handoffMessage: '',
  resolutionMessage: '',
  instructions: '',
  features: {
    conversationFaqs: false,
    memories: false,
  },
  temperature: 1,
};

const state = reactive({ ...initialState });

const validationRules = {
  name: { required, minLength: minLength(1) },
  description: { required, minLength: minLength(1) },
  productName: { required, minLength: minLength(1) },
  welcomeMessage: { minLength: minLength(1) },
  handoffMessage: { minLength: minLength(1) },
  resolutionMessage: { minLength: minLength(1) },
  instructions: { minLength: minLength(1) },
};

const v$ = useVuelidate(validationRules, state);

const isLoading = computed(() => formState.uiFlags.value.creatingItem);

const getErrorMessage = field => {
  return v$.value[field].$error ? v$.value[field].$errors[0].$message : '';
};

const formErrors = computed(() => ({
  name: getErrorMessage('name'),
  description: getErrorMessage('description'),
  productName: getErrorMessage('productName'),
  welcomeMessage: getErrorMessage('welcomeMessage'),
  handoffMessage: getErrorMessage('handoffMessage'),
  resolutionMessage: getErrorMessage('resolutionMessage'),
  instructions: getErrorMessage('instructions'),
}));

const updateStateFromTopic = topic => {
  const { config = {} } = topic;
  state.name = topic.name;
  state.description = topic.description;
  state.productName = config.product_name;
  state.welcomeMessage = config.welcome_message;
  state.handoffMessage = config.handoff_message;
  state.resolutionMessage = config.resolution_message;
  state.instructions = config.instructions;
  state.features = {
    conversationFaqs: config.feature_faq || false,
    memories: config.feature_memory || false,
  };
  state.temperature = config.temperature || 1;
};

const handleBasicInfoUpdate = async () => {
  const result = await Promise.all([
    v$.value.name.$validate(),
    v$.value.description.$validate(),
    v$.value.productName.$validate(),
  ]).then(results => results.every(Boolean));
  if (!result) return;

  const payload = {
    name: state.name,
    description: state.description,
    config: {
      ...props.topic.config,
      product_name: state.productName,
    },
  };

  emit('submit', payload);
};

const handleSystemMessagesUpdate = async () => {
  const result = await Promise.all([
    v$.value.welcomeMessage.$validate(),
    v$.value.handoffMessage.$validate(),
    v$.value.resolutionMessage.$validate(),
  ]).then(results => results.every(Boolean));
  if (!result) return;

  const payload = {
    config: {
      ...props.topic.config,
      welcome_message: state.welcomeMessage,
      handoff_message: state.handoffMessage,
      resolution_message: state.resolutionMessage,
    },
  };

  emit('submit', payload);
};

const handleInstructionsUpdate = async () => {
  const result = await v$.value.instructions.$validate();
  if (!result) return;

  const payload = {
    config: {
      ...props.topic.config,
      temperature: state.temperature || 1,
      instructions: state.instructions,
    },
  };

  emit('submit', payload);
};

const handleFeaturesUpdate = () => {
  const payload = {
    config: {
      ...props.topic.config,
      feature_faq: state.features.conversationFaqs,
      feature_memory: state.features.memories,
    },
  };

  emit('submit', payload);
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
    <!-- Basic Information Section -->
    <Accordion :title="t('AI_AGENT.TOPICS.FORM.SECTIONS.BASIC_INFO')" is-open>
      <div class="flex flex-col gap-4 pt-4">
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

        <div class="flex justify-end">
          <Button
            size="small"
            :loading="isLoading"
            @click="handleBasicInfoUpdate"
          >
            {{ t('AI_AGENT.TOPICS.FORM.UPDATE') }}
          </Button>
        </div>
      </div>
    </Accordion>

    <!-- Instructions Section -->
    <Accordion :title="t('AI_AGENT.TOPICS.FORM.SECTIONS.INSTRUCTIONS')">
      <div class="flex flex-col gap-4">
        <Editor
          v-model="state.instructions"
          :placeholder="t('AI_AGENT.TOPICS.FORM.INSTRUCTIONS.PLACEHOLDER')"
          :message="formErrors.instructions"
          :max-length="20000"
          :message-type="formErrors.instructions ? 'error' : 'info'"
        />

        <div class="flex flex-col gap-2 mt-4">
          <label class="text-sm font-medium text-n-slate-12">
            {{ t('AI_AGENT.TOPICS.FORM.TEMPERATURE.LABEL') }}
          </label>
          <div class="flex items-center gap-4">
            <input
              v-model="state.temperature"
              type="range"
              min="0"
              max="1"
              step="0.1"
              class="w-full"
            />
            <span class="text-sm text-n-slate-12">{{ state.temperature }}</span>
          </div>
          <p class="text-sm text-n-slate-11 italic">
            {{ t('AI_AGENT.TOPICS.FORM.TEMPERATURE.DESCRIPTION') }}
          </p>
        </div>
        <div class="flex justify-end">
          <Button
            size="small"
            :loading="isLoading"
            :label="t('AI_AGENT.TOPICS.FORM.UPDATE')"
            @click="handleInstructionsUpdate"
          />
        </div>
      </div>
    </Accordion>

    <!-- Greeting Messages Section -->
    <Accordion :title="t('AI_AGENT.TOPICS.FORM.SECTIONS.SYSTEM_MESSAGES')">
      <div class="flex flex-col gap-4 pt-4">
        <Editor
          v-model="state.handoffMessage"
          :label="t('AI_AGENT.TOPICS.FORM.HANDOFF_MESSAGE.LABEL')"
          :placeholder="t('AI_AGENT.TOPICS.FORM.HANDOFF_MESSAGE.PLACEHOLDER')"
          :message="formErrors.handoffMessage"
          :message-type="formErrors.handoffMessage ? 'error' : 'info'"
        />

        <Editor
          v-model="state.resolutionMessage"
          :label="t('AI_AGENT.TOPICS.FORM.RESOLUTION_MESSAGE.LABEL')"
          :placeholder="
            t('AI_AGENT.TOPICS.FORM.RESOLUTION_MESSAGE.PLACEHOLDER')
          "
          :message="formErrors.resolutionMessage"
          :message-type="formErrors.resolutionMessage ? 'error' : 'info'"
        />

        <div class="flex justify-end">
          <Button
            size="small"
            :loading="isLoading"
            :label="t('AI_AGENT.TOPICS.FORM.UPDATE')"
            @click="handleSystemMessagesUpdate"
          />
        </div>
      </div>
    </Accordion>

    <!-- Features Section -->
    <Accordion :title="t('AI_AGENT.TOPICS.FORM.SECTIONS.FEATURES')">
      <div class="flex flex-col gap-4 pt-4">
        <div class="flex flex-col gap-2">
          <label class="text-sm font-medium text-n-slate-12">
            {{ t('AI_AGENT.TOPICS.FORM.FEATURES.TITLE') }}
          </label>
          <div class="flex flex-col gap-2">
            <label class="flex items-center gap-2">
              <input
                v-model="state.features.conversationFaqs"
                type="checkbox"
                class="form-checkbox"
              />
              {{ t('AI_AGENT.TOPICS.FORM.FEATURES.ALLOW_CONVERSATION_FAQS') }}
            </label>
            <label class="flex items-center gap-2">
              <input
                v-model="state.features.memories"
                type="checkbox"
                class="form-checkbox"
              />
              {{ t('AI_AGENT.TOPICS.FORM.FEATURES.ALLOW_MEMORIES') }}
            </label>
          </div>
        </div>

        <div class="flex justify-end">
          <Button
            size="small"
            :loading="isLoading"
            :label="t('AI_AGENT.TOPICS.FORM.UPDATE')"
            @click="handleFeaturesUpdate"
          />
        </div>
      </div>
    </Accordion>
  </form>
</template>
