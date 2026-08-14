<script>
import { useVuelidate } from '@vuelidate/core';
import { required, minLength } from '@vuelidate/validators';
import { useAlert } from 'dashboard/composables';
import FormInput from '../../../components/Form/Input.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';
import { DEFAULT_REDIRECT_URL } from 'dashboard/constants/globals';
import { setNewPassword } from '../../../api/auth';
import AuthSplitLayout from '../../../components/Auth/SplitLayout.vue';
import { useStore } from 'vuex';
import { computed } from 'vue';

export default {
  components: {
    FormInput,
    NextButton,
    AuthSplitLayout,
  },
  props: {
    resetPasswordToken: { type: String, default: '' },
  },
  setup() {
    const store = useStore();
    const globalConfig = computed(() => store.getters['globalConfig/get']);
    return { v$: useVuelidate(), globalConfig };
  },
  data() {
    return {
      // We need to initialize the component with any
      // properties that will be used in it
      credentials: {
        confirmPassword: '',
        password: '',
      },
      newPasswordAPI: {
        message: '',
        showLoading: false,
      },
      error: '',
    };
  },
  mounted() {
    // If url opened without token
    // redirect to login
    if (!this.resetPasswordToken) {
      window.location = DEFAULT_REDIRECT_URL;
    }
  },
  validations: {
    credentials: {
      password: {
        required,
        minLength: minLength(6),
      },
      confirmPassword: {
        required,
        minLength: minLength(6),
        isEqPassword(value) {
          if (value !== this.credentials.password) {
            return false;
          }
          return true;
        },
      },
    },
  },
  methods: {
    showAlertMessage(message) {
      // Reset loading, current selected agent
      this.newPasswordAPI.showLoading = false;
      useAlert(message);
    },
    submitForm() {
      this.newPasswordAPI.showLoading = true;
      const credentials = {
        confirmPassword: this.credentials.confirmPassword,
        password: this.credentials.password,
        resetPasswordToken: this.resetPasswordToken,
      };
      setNewPassword(credentials)
        .then(() => {
          window.location = DEFAULT_REDIRECT_URL;
        })
        .catch(error => {
          this.showAlertMessage(
            error?.message || this.$t('SET_NEW_PASSWORD.API.ERROR_MESSAGE')
          );
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
      @submit.prevent="submitForm"
    >
      <h1
        class="mb-1 text-2xl font-medium tracking-tight text-left text-n-slate-12"
      >
        {{ $t('SET_NEW_PASSWORD.TITLE') }}
      </h1>

      <div class="space-y-5">
        <FormInput
          v-model="credentials.password"
          class="mt-3"
          name="password"
          type="password"
          :has-error="v$.credentials.password.$error"
          :error-message="$t('SET_NEW_PASSWORD.PASSWORD.ERROR')"
          :placeholder="$t('SET_NEW_PASSWORD.PASSWORD.PLACEHOLDER')"
          @blur="v$.credentials.password.$touch"
        />
        <FormInput
          v-model="credentials.confirmPassword"
          class="mt-3"
          name="confirm_password"
          type="password"
          :has-error="v$.credentials.confirmPassword.$error"
          :error-message="$t('SET_NEW_PASSWORD.CONFIRM_PASSWORD.ERROR')"
          :placeholder="$t('SET_NEW_PASSWORD.CONFIRM_PASSWORD.PLACEHOLDER')"
          @blur="v$.credentials.confirmPassword.$touch"
        />
        <NextButton
          lg
          type="submit"
          data-testid="submit_button"
          class="w-full"
          :label="$t('SET_NEW_PASSWORD.SUBMIT')"
          :disabled="
            v$.credentials.password.$invalid ||
            v$.credentials.confirmPassword.$invalid ||
            newPasswordAPI.showLoading
          "
          :is-loading="newPasswordAPI.showLoading"
        />
      </div>
    </form>
  </AuthSplitLayout>
</template>
