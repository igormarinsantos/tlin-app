<script setup>
import { useI18n } from 'vue-i18n';

defineProps({
  logo: { type: String, required: true },
  logoDark: { type: String, default: '' },
  installationName: { type: String, required: true },
});

const { t } = useI18n();
const loginHero = '/brand-assets/login-hero.jpg';
</script>

<template>
  <main
    class="h-screen min-h-screen max-h-screen overflow-hidden bg-n-background p-3 font-sans sm:p-6"
  >
    <div
      class="mx-auto grid h-full min-h-full max-h-full max-w-[1440px] grid-cols-1 overflow-hidden rounded-[2rem] bg-n-surface-1 lg:grid-cols-2"
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

        <div class="my-auto w-full max-w-[30rem] py-8 lg:py-12">
          <h1
            class="text-4xl font-semibold tracking-tight text-n-slate-12 sm:text-5xl"
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
            :src="loginHero"
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
