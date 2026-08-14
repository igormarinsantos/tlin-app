<script setup>
const upgradeUrl = 'mailto:suporte@tlin.ai?subject=Quero%20assinar%20o%20Tlin';

// Replace upgradeUrl with the checkout session URL when payments are integrated.
</script>

<template>
  <main
    class="flex min-h-screen w-full items-center justify-center bg-n-background p-6"
  >
    <section
      class="w-full max-w-xl rounded-[2rem] bg-n-surface-1 p-8 text-center shadow-xl sm:p-12"
    >
      <div
        class="mx-auto mb-6 flex size-14 items-center justify-center rounded-full bg-tlin-gradient text-xl text-n-black"
      >
        <span class="i-lucide-clock-3" />
      </div>
      <h1 class="mb-3 text-3xl font-bold text-n-slate-12">
        {{ $t('APP_GLOBAL.TLIN_TRIAL.ENDED_TITLE') }}
      </h1>
      <p class="mx-auto mb-8 max-w-md text-base text-n-slate-11">
        {{ $t('APP_GLOBAL.TLIN_TRIAL.ENDED_MESSAGE') }}
      </p>
      <a
        :href="upgradeUrl"
        class="inline-flex items-center justify-center rounded-full bg-tlin-gradient px-6 py-3 font-semibold text-n-black transition-transform hover:scale-[1.02]"
      >
        {{ $t('APP_GLOBAL.TLIN_TRIAL.SUBSCRIBE') }}
      </a>
    </section>
  </main>
</template>
