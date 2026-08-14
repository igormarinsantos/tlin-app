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
  <main class="flex flex-1 items-center justify-center w-full min-h-full p-6">
    <section
      class="w-full max-w-2xl overflow-hidden rounded-[2rem] border border-n-weak bg-n-solid-1 shadow-xl shadow-n-slate-12/5"
    >
      <div class="bg-tlin-gradient p-8 text-n-slate-12 sm:p-10">
        <span
          class="inline-flex items-center justify-center size-12 rounded-full bg-white/35 text-2xl"
          aria-hidden="true"
        >
          🔒
        </span>
        <h1 class="mt-6 text-3xl font-bold tracking-tight sm:text-4xl">
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
          v-if="activationRequested"
          class="mt-4 rounded-full bg-n-alpha-2 px-4 py-2 text-sm font-medium text-n-slate-11"
          role="status"
        >
          {{ $t('TLIN_AI_AGENT.AVAILABILITY') }}
        </p>
      </div>
    </section>
  </main>
</template>
