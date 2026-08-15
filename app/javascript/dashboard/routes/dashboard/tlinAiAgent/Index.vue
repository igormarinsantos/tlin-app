<script setup>
import { ref } from 'vue';

import Button from 'dashboard/components-next/button/Button.vue';

const activationRequested = ref(false);

const requestActivation = () => {
  // Replace this local state with the provisioning flow for fazer-ai/agents
  // once the external engine and Scale entitlement are connected.
  activationRequested.value = true;
};
</script>

<template>
  <main
    class="fixed inset-0 z-40 flex min-h-[100dvh] items-center justify-center overflow-y-auto p-4 sm:p-6"
  >
    <div
      class="absolute inset-0 bg-n-slate-12/35 backdrop-blur-md"
      aria-hidden="true"
    />
    <section
      class="relative z-10 my-auto w-full max-w-2xl overflow-hidden rounded-[2rem] border border-n-weak bg-n-solid-1 shadow-2xl shadow-n-slate-12/30"
      role="dialog"
      aria-modal="true"
      aria-labelledby="tlin-upsell-title"
    >
      <div class="bg-tlin-gradient p-8 text-n-slate-12 sm:p-10">
        <span
          class="i-lucide-lock-keyhole inline-flex size-12 items-center justify-center rounded-full bg-white/35 text-2xl"
          aria-hidden="true"
        />
        <h1
          id="tlin-upsell-title"
          class="mt-6 text-3xl font-bold tracking-tight sm:text-4xl"
        >
          {{ $t('TLIN_AI_AGENT.TITLE') }}
        </h1>
        <p class="mt-3 max-w-xl text-base font-medium sm:text-lg">
          {{ $t('TLIN_AI_AGENT.DESCRIPTION') }}
        </p>
      </div>

      <div class="p-8 sm:p-10">
        <p class="text-sm leading-6 text-n-slate-11">
          {{ $t('TLIN_AI_AGENT.DETAIL') }}
        </p>
        <Button
          class="mt-8"
          :label="$t('TLIN_AI_AGENT.ACTIVATE')"
          size="lg"
          @click="requestActivation"
        />
        <p
          class="mt-4 text-sm text-n-slate-11"
          :class="{
            'rounded-full bg-n-alpha-2 px-4 py-2 font-medium':
              activationRequested,
          }"
          role="status"
        >
          {{ $t('TLIN_AI_AGENT.AVAILABILITY') }}
        </p>
      </div>
    </section>
  </main>
</template>
