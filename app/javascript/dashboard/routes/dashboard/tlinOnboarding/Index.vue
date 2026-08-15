<script setup>
import { computed, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';

import { useAccount } from 'dashboard/composables/useAccount';
import { useStore } from 'dashboard/composables/store';
import { frontendURL } from 'dashboard/helper/URLHelper';
import Button from 'dashboard/components-next/button/Button.vue';

const { t } = useI18n();
const router = useRouter();
const store = useStore();
const { accountId, finishOnboarding } = useAccount();
const lightLogoUrl = '/brand-assets/logo.svg';
const darkLogoUrl = '/brand-assets/logo_dark.svg';

const step = ref(0);
const isSaving = ref(false);
const showValidation = ref(false);
const leadContactName = ref('');
const leadWhatsapp = ref('');
const referralSource = ref('');
const businessType = ref('');
const businessOffer = ref('');

const steps = computed(() => [
  {
    key: 'name',
    required: true,
    title: t('TLIN_ONBOARDING.NAME.TITLE'),
    description: t('TLIN_ONBOARDING.NAME.DESCRIPTION'),
  },
  {
    key: 'whatsapp',
    required: true,
    title: t('TLIN_ONBOARDING.WHATSAPP.TITLE'),
    description: t('TLIN_ONBOARDING.WHATSAPP.DESCRIPTION'),
  },
  {
    key: 'referral',
    title: t('TLIN_ONBOARDING.REFERRAL.TITLE'),
    description: t('TLIN_ONBOARDING.REFERRAL.DESCRIPTION'),
  },
  {
    key: 'businessType',
    title: t('TLIN_ONBOARDING.BUSINESS_TYPE.TITLE'),
    description: t('TLIN_ONBOARDING.BUSINESS_TYPE.DESCRIPTION'),
  },
  {
    key: 'businessOffer',
    title: t('TLIN_ONBOARDING.BUSINESS_OFFER.TITLE'),
    description: t('TLIN_ONBOARDING.BUSINESS_OFFER.DESCRIPTION'),
  },
]);

const currentStep = computed(() => steps.value[step.value]);
const isLastStep = computed(() => step.value === steps.value.length - 1);
const validationError = computed(() =>
  currentStep.value.key === 'name'
    ? t('TLIN_ONBOARDING.NAME.ERROR')
    : t('TLIN_ONBOARDING.WHATSAPP.ERROR')
);
const normalizedWhatsapp = computed(() =>
  leadWhatsapp.value.replace(/\s/g, '')
);
const isWhatsappValid = computed(() =>
  /^\+[1-9]\d{7,14}$/.test(normalizedWhatsapp.value)
);

const isCurrentStepValid = () => {
  if (currentStep.value.key === 'name')
    return leadContactName.value.trim().length > 0;
  if (currentStep.value.key === 'whatsapp') return isWhatsappValid.value;
  return true;
};

const continueOnboarding = async () => {
  if (!isCurrentStepValid()) {
    showValidation.value = true;
    return;
  }

  showValidation.value = false;
  if (!isLastStep.value) {
    step.value += 1;
    return;
  }

  isSaving.value = true;
  try {
    // These keys are persisted on Account.custom_attributes. Marketing can
    // export them now; the future external agent setup should consume them here.
    await finishOnboarding({
      lead_contact_name: leadContactName.value.trim(),
      lead_whatsapp: normalizedWhatsapp.value,
      referral_source: referralSource.value,
      business_type: businessType.value,
      business_offer: businessOffer.value.trim(),
    });
    store.commit('RESET_ONBOARDING', accountId.value);
    router.push(frontendURL(`accounts/${accountId.value}/dashboard`));
  } finally {
    isSaving.value = false;
  }
};

const skipStep = () => {
  if (!isLastStep.value) step.value += 1;
  else continueOnboarding();
};
</script>

<template>
  <main class="grid min-h-full w-full bg-n-background lg:grid-cols-2">
    <section
      class="flex min-h-[42vh] flex-col bg-n-solid-1 px-6 py-8 sm:px-10 lg:min-h-full lg:px-16 lg:py-12"
    >
      <header>
        <img
          :src="lightLogoUrl"
          alt="Tlin"
          class="block h-8 w-auto dark:hidden"
        />
        <img
          :src="darkLogoUrl"
          alt="Tlin"
          class="hidden h-8 w-auto dark:block"
        />
      </header>

      <div class="my-auto max-w-xl py-10 lg:py-16">
        <h1
          class="text-4xl font-semibold leading-tight tracking-tight text-n-slate-12 sm:text-5xl"
        >
          {{ currentStep.title }}
        </h1>
        <p class="mt-5 max-w-lg text-base leading-7 text-n-slate-11 sm:text-lg">
          {{ currentStep.description }}
        </p>
      </div>
    </section>

    <section
      class="flex min-h-[58vh] items-center bg-n-background px-6 py-10 sm:px-10 lg:min-h-full lg:px-16 lg:py-12"
    >
      <div class="mx-auto w-full max-w-md">
        <div class="w-full">
          <input
            v-if="currentStep.key === 'name'"
            v-model="leadContactName"
            class="h-12 w-full rounded-full border border-n-weak bg-n-background px-5 text-base text-n-slate-12 outline-none focus:border-n-brand"
            :aria-label="currentStep.title"
            :placeholder="$t('TLIN_ONBOARDING.NAME.PLACEHOLDER')"
            autocomplete="name"
            @keyup.enter="continueOnboarding"
          />
          <input
            v-else-if="currentStep.key === 'whatsapp'"
            v-model="leadWhatsapp"
            class="h-12 w-full rounded-full border border-n-weak bg-n-background px-5 text-base text-n-slate-12 outline-none focus:border-n-brand"
            :aria-label="currentStep.title"
            :placeholder="$t('TLIN_ONBOARDING.WHATSAPP.PLACEHOLDER')"
            autocomplete="tel"
            inputmode="tel"
            @keyup.enter="continueOnboarding"
          />
          <select
            v-else-if="currentStep.key === 'referral'"
            v-model="referralSource"
            class="h-12 w-full rounded-full border border-n-weak bg-n-background px-5 text-base text-n-slate-12 outline-none focus:border-n-brand"
            :aria-label="currentStep.title"
          >
            <option value="">
              {{ $t('TLIN_ONBOARDING.SELECT_PLACEHOLDER') }}
            </option>
            <option value="google">
              {{ $t('TLIN_ONBOARDING.REFERRAL.GOOGLE') }}
            </option>
            <option value="instagram">
              {{ $t('TLIN_ONBOARDING.REFERRAL.INSTAGRAM') }}
            </option>
            <option value="referral">
              {{ $t('TLIN_ONBOARDING.REFERRAL.REFERRAL') }}
            </option>
            <option value="ad">{{ $t('TLIN_ONBOARDING.REFERRAL.AD') }}</option>
            <option value="other">{{ $t('TLIN_ONBOARDING.OTHER') }}</option>
          </select>
          <select
            v-else-if="currentStep.key === 'businessType'"
            v-model="businessType"
            class="h-12 w-full rounded-full border border-n-weak bg-n-background px-5 text-base text-n-slate-12 outline-none focus:border-n-brand"
            :aria-label="currentStep.title"
          >
            <option value="">
              {{ $t('TLIN_ONBOARDING.SELECT_PLACEHOLDER') }}
            </option>
            <option value="clinic">
              {{ $t('TLIN_ONBOARDING.BUSINESS_TYPE.CLINIC') }}
            </option>
            <option value="store">
              {{ $t('TLIN_ONBOARDING.BUSINESS_TYPE.STORE') }}
            </option>
            <option value="services">
              {{ $t('TLIN_ONBOARDING.BUSINESS_TYPE.SERVICES') }}
            </option>
            <option value="agency">
              {{ $t('TLIN_ONBOARDING.BUSINESS_TYPE.AGENCY') }}
            </option>
            <option value="other">{{ $t('TLIN_ONBOARDING.OTHER') }}</option>
          </select>
          <textarea
            v-else
            v-model="businessOffer"
            class="min-h-32 w-full rounded-[1.5rem] border border-n-weak bg-n-background p-5 text-base text-n-slate-12 outline-none focus:border-n-brand"
            :aria-label="currentStep.title"
            :placeholder="$t('TLIN_ONBOARDING.BUSINESS_OFFER.PLACEHOLDER')"
          />
          <p
            v-if="showValidation"
            class="mt-3 text-sm font-medium text-n-ruby-11"
          >
            {{ validationError }}
          </p>

          <div class="mt-8 flex flex-wrap items-center gap-3">
            <Button
              :is-loading="isSaving"
              :label="
                isLastStep
                  ? $t('TLIN_ONBOARDING.FINISH')
                  : $t('TLIN_ONBOARDING.CONTINUE')
              "
              size="lg"
              @click="continueOnboarding"
            />
            <Button
              v-if="!currentStep.required"
              variant="ghost"
              :label="$t('TLIN_ONBOARDING.SKIP')"
              size="lg"
              @click="skipStep"
            />
          </div>
        </div>
      </div>
    </section>
  </main>
</template>
