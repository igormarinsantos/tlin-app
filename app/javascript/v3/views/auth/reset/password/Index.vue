<script>
import { useVuelidate } from '@vuelidate/core';
import { useAlert } from 'dashboard/composables';
import { required, minLength, email } from '@vuelidate/validators';
import { useBranding } from 'shared/composables/useBranding';
import FormInput from '../../../../components/Form/Input.vue';
import { resetPassword } from '../../../../api/auth';
import NextButton from 'dashboard/components-next/button/Button.vue';
import AuthSplitLayout from '../../../../components/Auth/SplitLayout.vue';
import { useStore } from 'vuex';
import { computed } from 'vue';

export default {
  components: { FormInput, NextButton, AuthSplitLayout },
  setup() {
    const { replaceInstallationName } = useBranding();
    const store = useStore();
    const globalConfig = computed(() => store.getters['globalConfig/get']);
    return {
      v$: useVuelidate(),
      replaceInstallationName,
      globalConfig,
    };
  },
  data() {
    return {
      credentials: { email: '' },
      resetPassword: {
        message: '',
        showLoading: false,
      },
      error: '',
    };
  },
  validations() {
    return {
      credentials: {
        email: {
          required,
          email,
          minLength: minLength(4),
        },
      },
    };
  },
  methods: {
    showAlertMessage(message) {
      // Reset loading, current selected agent
      this.resetPassword.showLoading = false;
      useAlert(message);
    },
    submit() {
      this.resetPassword.showLoading = true;
      resetPassword(this.credentials)
        .then(res => {
          let successMessage = this.$t('RESET_PASSWORD.API.SUCCESS_MESSAGE');
          if (res.data && res.data.message) {
            successMessage = res.data.message;
          }
          this.showAlertMessage(successMessage);
        })
        .catch(error => {
          let errorMessage = this.$t('RESET_PASSWORD.API.ERROR_MESSAGE');
          if (error?.response?.data?.message) {
            errorMessage = error.response.data.message;
          }
          this.showAlertMessage(errorMessage);
        });
    },
  },
};
</script>

<template>
  <AuthSplitLayout
    :logo="globalConfig.logo"
    :logo-dark="globalConfig.logoDark"
    :installation-name="globalConfig.installationName"
  >
    <form
      class="w-full rounded-[1.5rem] border border-n-weak bg-white p-6 shadow-xl shadow-n-slate-12/5 dark:bg-n-solid-2 sm:p-8"
      @submit.prevent="submit"
    >
      <h1
        class="mb-1 text-2xl font-medium tracking-tight text-left text-n-slate-12"
      >
        {{ $t('RESET_PASSWORD.TITLE') }}
      </h1>
      <p
        class="mb-4 text-sm font-normal leading-6 tracking-normal text-n-slate-11"
      >
        {{ replaceInstallationName($t('RESET_PASSWORD.DESCRIPTION')) }}
      </p>
      <div class="space-y-5">
        <FormInput
          v-model="credentials.email"
          name="email_address"
          :has-error="v$.credentials.email.$error"
          :error-message="$t('RESET_PASSWORD.EMAIL.ERROR')"
          :placeholder="$t('RESET_PASSWORD.EMAIL.PLACEHOLDER')"
          @input="v$.credentials.email.$touch"
        />
        <NextButton
          lg
          type="submit"
          data-testid="submit_button"
          class="w-full"
          :label="$t('RESET_PASSWORD.SUBMIT')"
          :disabled="v$.credentials.email.$invalid || resetPassword.showLoading"
          :is-loading="resetPassword.showLoading"
        />
      </div>
      <p class="mt-4 -mb-1 text-sm text-n-slate-11">
        {{ $t('RESET_PASSWORD.GO_BACK_TO_LOGIN') }}
        <router-link to="/auth/login" class="text-link text-n-brand">
          {{ $t('COMMON.CLICK_HERE') }}.
        </router-link>
      </p>
    </form>
  </AuthSplitLayout>
</template>
