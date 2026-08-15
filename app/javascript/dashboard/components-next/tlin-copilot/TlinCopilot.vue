<script setup>
import { computed, ref } from 'vue';
import { useI18n } from 'vue-i18n';

import Button from 'dashboard/components-next/button/Button.vue';
import TlinCopilotApi from 'dashboard/api/tlinCopilot';

const props = defineProps({
  conversationId: { type: [String, Number], required: true },
});

const emit = defineEmits(['insert']);
const { t } = useI18n();
const isMenuOpen = ref(false);
const activeSkill = ref('');
const suggestion = ref('');
const error = ref('');
const copied = ref(false);

const skills = computed(() => [
  {
    key: 'resumir',
    label: t('TLIN_COPILOT.SKILLS.SUMMARIZE.LABEL'),
    description: t('TLIN_COPILOT.SKILLS.SUMMARIZE.DESCRIPTION'),
  },
  {
    key: 'objecao',
    label: t('TLIN_COPILOT.SKILLS.OBJECTION.LABEL'),
    description: t('TLIN_COPILOT.SKILLS.OBJECTION.DESCRIPTION'),
  },
  {
    key: 'resposta',
    label: t('TLIN_COPILOT.SKILLS.REPLY.LABEL'),
    description: t('TLIN_COPILOT.SKILLS.REPLY.DESCRIPTION'),
  },
]);

const isThinking = computed(() => !!activeSkill.value);

const generate = async skill => {
  activeSkill.value = skill.key;
  isMenuOpen.value = false;
  error.value = '';
  copied.value = false;

  try {
    const { data } = await TlinCopilotApi.suggest({
      conversation_id: props.conversationId,
      skill: skill.key,
    });
    suggestion.value = data.suggestion;
  } catch (requestError) {
    error.value = requestError.response?.data?.error || t('TLIN_COPILOT.ERROR');
  } finally {
    activeSkill.value = '';
  }
};

const copySuggestion = async () => {
  await navigator.clipboard.writeText(suggestion.value);
  copied.value = true;
};

const insertSuggestion = () => {
  emit('insert', suggestion.value);
};

const closeSuggestion = () => {
  suggestion.value = '';
  error.value = '';
};
</script>

<template>
  <div class="relative mt-3">
    <Button
      icon="i-lucide-sparkles"
      :label="$t('TLIN_COPILOT.TRIGGER')"
      size="sm"
      @click="isMenuOpen = !isMenuOpen"
    />

    <div
      v-if="isMenuOpen"
      class="absolute bottom-full left-0 z-30 mb-2 w-80 rounded-2xl border border-n-weak bg-n-solid-1 p-2 shadow-xl shadow-black/20"
    >
      <button
        v-for="skill in skills"
        :key="skill.key"
        type="button"
        class="flex w-full flex-col rounded-xl px-3 py-2 text-left transition-colors hover:bg-n-alpha-2"
        :disabled="isThinking"
        @click="generate(skill)"
      >
        <span class="text-sm font-semibold text-n-slate-12">{{
          skill.label
        }}</span>
        <span class="mt-0.5 text-xs text-n-slate-11">{{
          skill.description
        }}</span>
      </button>
    </div>

    <div
      v-if="isThinking || suggestion || error"
      class="mt-3 rounded-2xl border border-n-weak bg-n-solid-1 p-4 shadow-lg shadow-black/10"
    >
      <div class="flex items-center justify-between gap-3">
        <div
          class="flex items-center gap-2 text-sm font-semibold text-n-slate-12"
        >
          <span
            class="i-lucide-sparkles size-4 text-n-brand"
            aria-hidden="true"
          />
          {{ $t('TLIN_COPILOT.TITLE') }}
        </div>
        <button
          type="button"
          class="inline-flex size-7 items-center justify-center rounded-full text-n-slate-11 hover:bg-n-alpha-2"
          :aria-label="$t('CLOSE')"
          @click="closeSuggestion"
        >
          <span class="i-lucide-x size-4" aria-hidden="true" />
        </button>
      </div>

      <div
        v-if="isThinking"
        class="mt-3 flex items-center gap-2 text-sm text-n-slate-11"
      >
        <span
          class="i-lucide-loader-circle size-4 animate-spin"
          aria-hidden="true"
        />
        {{ $t('TLIN_COPILOT.THINKING') }}
      </div>
      <p v-else-if="error" class="mt-3 text-sm text-n-ruby-11">{{ error }}</p>
      <template v-else>
        <p class="mt-3 whitespace-pre-wrap text-sm leading-6 text-n-slate-12">
          {{ suggestion }}
        </p>
        <div class="mt-4 flex flex-wrap gap-2">
          <Button
            icon="i-lucide-clipboard"
            :label="
              copied ? $t('TLIN_COPILOT.COPIED') : $t('TLIN_COPILOT.COPY')
            "
            color="slate"
            variant="faded"
            size="sm"
            @click="copySuggestion"
          />
          <Button
            icon="i-lucide-arrow-down-to-line"
            :label="$t('TLIN_COPILOT.INSERT')"
            size="sm"
            @click="insertSuggestion"
          />
        </div>
      </template>
    </div>
  </div>
</template>
