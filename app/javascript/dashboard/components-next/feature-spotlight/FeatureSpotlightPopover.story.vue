<script setup>
import FeatureSpotlightPopover from './FeatureSpotlightPopover.vue';
</script>

<template>
  <Story
    title="Components/FeatureSpotlight/Popup"
    :layout="{ type: 'grid', width: '800px' }"
  >
    <Variant title="Default with learn more URL">
      <div class="p-6 h-[450px] bg-n-background">
        <div class="flex gap-8">
          <FeatureSpotlightPopover
            button-label="Learn about Topic"
            title="AI Agent Topic"
            note="AI Agent Topic engages directly with customers, learns from your help docs and past conversations, and delivers instant, accurate responses. It handles the initial queries, providing quick resolutions before transferring to an agent when needed."
            video-url=""
            thumbnail=""
            fallback-thumbnail="/assets/images/dashboard/aiagent/topic-popover-light.svg"
            fallback-thumbnail-dark="/assets/images/dashboard/aiagent/topic-popover-dark.svg"
            learn-more-url="https://www.chatwoot.com/hc/user-guide/articles/1738101547-creating-an-topic-with-aiagent"
          />
        </div>
      </div>
    </Variant>

    <Variant title="With Video Thumbnail and URL">
      <div class="p-6 h-[450px] bg-n-background">
        <div class="flex gap-8">
          <FeatureSpotlightPopover
            button-label="Learn about Topic"
            title="AI Agent Topic"
            note="AI Agent Topic engages directly with customers, learns from your help docs and past conversations, and delivers instant, accurate responses. It handles the initial queries, providing quick resolutions before transferring to an agent when needed."
            video-url="https://www.youtube.com/watch?v=E4xUHyAAktY"
            thumbnail="https://i.ytimg.com/an_webp/E4xUHyAAktY/mqdefault_6s.webp?du=3000&sqp=CJaKmL4G&rs=AOn4CLCmfy1TMOcW4UsjQTgyKRp4TSGZgg"
            fallback-thumbnail="/assets/images/dashboard/aiagent/topic-popover-light.svg"
            fallback-thumbnail-dark="/assets/images/dashboard/aiagent/topic-popover-dark.svg"
            learn-more-url="https://www.chatwoot.com/hc/user-guide/articles/1738101547-creating-an-topic-with-aiagent"
          />
        </div>
      </div>
    </Variant>
  </Story>
</template>
