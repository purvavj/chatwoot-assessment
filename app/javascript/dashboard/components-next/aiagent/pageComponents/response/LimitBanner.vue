<script setup>
import { onMounted, computed } from 'vue';
import { useAccount } from 'dashboard/composables/useAccount';
import { useAIAgent } from 'dashboard/composables/useAIAgent';
import { useRouter } from 'vue-router';

import Banner from 'dashboard/components-next/banner/Banner.vue';

const router = useRouter();
const { accountId } = useAccount();

const { responseLimits, fetchLimits } = useAIAgent();

const openBilling = () => {
  router.push({
    name: 'billing_settings_index',
    params: { accountId: accountId.value },
  });
};

const showBanner = computed(() => {
  if (!responseLimits.value) return false;

  const { consumed, totalCount } = responseLimits.value;
  if (!consumed || !totalCount) return false;

  return consumed / totalCount > 0.8;
});

onMounted(fetchLimits);
</script>

<template>
  <Banner
    v-show="showBanner"
    color="amber"
    :action-label="$t('AI_AGENT.PAYWALL.UPGRADE_NOW')"
    @action="openBilling"
  >
    {{ $t('AI_AGENT.BANNER.RESPONSES') }}
  </Banner>
</template>
