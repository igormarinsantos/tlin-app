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
  <main class="min-h-screen bg-n-background p-3 font-sans sm:p-6">
    <div
      class="mx-auto grid min-h-[calc(100vh-1.5rem)] max-w-[1440px] grid-cols-1 overflow-hidden rounded-[2rem] bg-n-surface-1 shadow-2xl shadow-n-slate-12/5 lg:min-h-[calc(100vh-3rem)] lg:grid-cols-2"
    >
      <section
        class="flex min-w-0 flex-col px-6 py-8 sm:px-10 lg:px-16 lg:py-12"
      >
        <header>
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

        <div class="my-auto w-full max-w-[30rem] py-12 lg:py-16">
          <p class="text-sm font-semibold tracking-wide text-n-blue-11">
            {{ t('AUTH_LAYOUT.EYEBROW') }}
          </p>
          <h1
            class="mt-3 text-4xl font-semibold tracking-tight text-n-slate-12 sm:text-5xl"
          >
            {{ t('AUTH_LAYOUT.TITLE') }}
          </h1>
          <p class="mt-4 max-w-md text-base leading-7 text-n-slate-11">
            {{ t('AUTH_LAYOUT.SUBTITLE') }}
          </p>

          <div class="mt-10 w-full">
            <slot />
          </div>
        </div>
      </section>

      <aside class="hidden p-3 lg:block">
        <div
          class="relative h-full min-h-[640px] overflow-hidden rounded-[1.5rem] bg-tlin-gradient"
        >
          <img
            :src="'/brand-assets/login-hero.jpg'"
            alt=""
            class="h-full w-full object-cover opacity-90 mix-blend-soft-light"
          />
          <div
            class="absolute inset-0 bg-gradient-to-t from-n-slate-12/30 via-transparent to-white/10"
          />
        </div>
      </aside>
    </div>
  </main>
</template>
