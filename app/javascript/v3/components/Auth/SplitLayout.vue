<script setup>
import { useI18n } from 'vue-i18n';

defineProps({
  logo: { type: String, required: true },
  logoDark: { type: String, default: '' },
  installationName: { type: String, required: true },
});

const { t } = useI18n();
</script>

<template>
  <main
    class="h-dvh min-h-dvh overflow-hidden bg-n-background p-3 font-sans sm:p-6"
  >
    <div
      class="mx-auto grid h-full min-h-0 max-w-[1440px] grid-cols-1 overflow-hidden rounded-[2rem] bg-n-surface-1 lg:grid-cols-2"
    >
      <section
        class="flex min-h-0 min-w-0 flex-col overflow-hidden px-6 py-5 sm:px-10 lg:px-14 lg:py-6"
      >
        <header class="shrink-0">
          <img
            :src="logo"
            :alt="installationName"
            class="block h-8 w-auto dark:hidden"
          />
          <img
            v-if="logoDark"
            :src="logoDark"
            :alt="installationName"
            class="hidden h-8 w-auto dark:block"
          />
        </header>

        <div class="my-auto mx-auto w-full max-w-[30rem] py-4 lg:py-6">
          <h1
            class="text-center text-[clamp(2rem,5vh,3rem)] font-semibold leading-[1.05] tracking-tight text-n-slate-12"
          >
            {{ t('AUTH_LAYOUT.TITLE') }}
          </h1>
          <p
            class="mx-auto mt-3 max-w-md text-center text-sm leading-6 text-n-slate-11 sm:text-base"
          >
            {{ t('AUTH_LAYOUT.SUBTITLE') }}
          </p>

          <div class="mt-6 w-full lg:mt-8">
            <slot />
          </div>
        </div>
      </section>

      <aside class="hidden p-3 lg:block">
        <div class="h-full min-h-[640px] rounded-[1.5rem] bg-tlin-gradient" />
      </aside>
    </div>
  </main>
</template>
