<script>
import SnackbarContainer from './components/SnackBar/Container.vue';

const DEFAULT_AUTH_LOCALE = 'pt_BR';
const AUTH_LOCALE_STORAGE_KEY = 'tlin.auth.locale';

export default {
  components: { SnackbarContainer },
  data() {
    return { theme: 'light' };
  },
  mounted() {
    this.setColorTheme();
    this.listenToThemeChanges();
    this.setLocale();
  },
  methods: {
    setColorTheme() {
      if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
        this.theme = 'dark';
        document.documentElement.classList.add('dark');
      } else {
        this.theme = 'light';
        document.documentElement.classList.remove('dark');
      }
    },
    listenToThemeChanges() {
      const mql = window.matchMedia('(prefers-color-scheme: dark)');

      mql.onchange = e => {
        if (e.matches) {
          this.theme = 'dark';
          document.documentElement.classList.add('dark');
        } else {
          this.theme = 'light';
          document.documentElement.classList.remove('dark');
        }
      };
    },
    setLocale() {
      const storedLocale = window.localStorage.getItem(AUTH_LOCALE_STORAGE_KEY);
      const browserLocale = window.navigator.language?.replace('-', '_');
      const localeCandidates = [
        storedLocale,
        browserLocale?.startsWith('pt') ? DEFAULT_AUTH_LOCALE : browserLocale,
        browserLocale?.split('_')[0],
        window.chatwootConfig.selectedLocale,
        DEFAULT_AUTH_LOCALE,
      ];
      const locale = localeCandidates.find(candidate =>
        this.$root.$i18n.availableLocales.includes(candidate)
      );

      this.$root.$i18n.locale = locale || DEFAULT_AUTH_LOCALE;
    },
  },
};
</script>

<template>
  <div class="h-full min-h-screen w-full antialiased" :class="theme">
    <router-view />
    <SnackbarContainer />
  </div>
</template>

<style lang="scss">
@tailwind base;
@tailwind components;
@tailwind utilities;

@import '../dashboard/assets/scss/next-colors';
@import '../shared/assets/fonts/dm-sans';

html,
body {
  font-family:
    'DM Sans',
    -apple-system,
    BlinkMacSystemFont,
    'Segoe UI',
    Roboto,
    'Helvetica Neue',
    sans-serif;
  @apply h-full w-full;

  input,
  select {
    outline: none;
  }
}

.text-link {
  @apply text-n-brand font-medium hover:text-n-blue-10;
}

.v-popper--theme-tooltip .v-popper__inner {
  background: black !important;
  font-size: 0.75rem;
  padding: 4px 8px !important;
  border-radius: 6px;
  font-weight: 400;
}

.v-popper--theme-tooltip .v-popper__arrow-container {
  display: none;
}
</style>
