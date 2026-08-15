<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';

import Button from 'dashboard/components-next/button/Button.vue';
import { useAccount } from 'dashboard/composables/useAccount';
import { frontendURL } from 'dashboard/helper/URLHelper';

const activationRequested = ref(false);
const router = useRouter();
const { accountId } = useAccount();

const requestActivation = () => {
  // Replace this local state with the provisioning flow for fazer-ai/agents
  // once the external engine and Scale entitlement are connected.
  activationRequested.value = true;
};

const closePopup = () => {
  router.push(frontendURL(`accounts/${accountId.value}/dashboard`));
};
</script>

<template>
  <main
    class="absolute inset-0 z-40 flex items-center justify-center overflow-y-auto p-4 sm:p-6"
  >
    <div
      class="absolute inset-0 bg-black/75 backdrop-blur-lg"
      aria-hidden="true"
      @click="closePopup"
    />
    <section
      class="relative z-10 my-auto w-full max-w-2xl overflow-hidden rounded-[2rem] border border-white/10 bg-n-solid-1 shadow-2xl shadow-black/50"
      role="dialog"
      aria-modal="true"
      aria-labelledby="tlin-upsell-title"
    >
      <div class="relative bg-tlin-gradient p-8 text-n-black sm:p-10">
        <button
          type="button"
          class="absolute right-5 top-5 inline-flex size-9 items-center justify-center rounded-full bg-black/15 text-n-black transition-colors hover:bg-black/25 focus-visible:outline focus-visible:outline-2 focus-visible:outline-n-black"
          :aria-label="$t('CLOSE')"
          @click="closePopup"
        >
          <span class="i-lucide-x size-5" aria-hidden="true" />
        </button>
        <span
          class="i-lucide-sparkles inline-flex size-12 items-center justify-center rounded-full bg-black/15 text-2xl"
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
