<script setup>
import { computed } from 'vue';
import { useStore } from 'vuex';
import SignupForm from './components/Signup/Form.vue';
import AuthSplitLayout from '../../../components/Auth/SplitLayout.vue';

const store = useStore();

const globalConfig = computed(() => store.getters['globalConfig/get']);
const isAChatwootInstance = computed(
  () => globalConfig.value.installationName === 'Chatwoot'
);
</script>

<template>
  <AuthSplitLayout
    :logo="globalConfig.logo"
    :logo-dark="globalConfig.logoDark"
    :installation-name="globalConfig.installationName"
  >
    <div
      class="w-full rounded-[1.5rem] border border-n-weak bg-white p-6 shadow-xl shadow-n-slate-12/5 dark:bg-n-solid-2 sm:p-8"
    >
      <div class="mb-6">
        <h2 class="text-2xl font-semibold text-n-slate-12">
          {{
            isAChatwootInstance
              ? $t('REGISTER.GET_STARTED')
              : $t('REGISTER.TRY_WOOT')
          }}
        </h2>
        <p class="mt-2 text-sm text-n-slate-11">
          {{ $t('REGISTER.HAVE_AN_ACCOUNT') }}{{ ' '
          }}<router-link class="font-medium text-n-blue-11" to="/app/login">
            {{ $t('LOGIN.SUBMIT') }}
          </router-link>
        </p>
      </div>
      <SignupForm />
    </div>
  </AuthSplitLayout>
</template>
