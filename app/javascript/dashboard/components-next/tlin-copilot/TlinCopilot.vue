<script setup>
import { computed, ref } from 'vue';
import { useI18n } from 'vue-i18n';

import Button from 'dashboard/components-next/button/Button.vue';
import TlinCopilotApi from 'dashboard/api/tlinCopilot';

const props = defineProps({
  conversationId: { type: [String, Number], required: true },
  disabled: { type: Boolean, default: false },
  placement: {
    type: String,
    default: 'bottom',
    validator: value => ['top', 'bottom'].includes(value),
  },
  resultPlacement: {
    type: String,
    default: 'inline',
    validator: value => ['drawer', 'inline'].includes(value),
  },
});

const emit = defineEmits(['insert']);
const { t } = useI18n();
const isMenuOpen = ref(false);
const activeSkill = ref('');
const suggestion = ref('');
const error = ref('');
const copied = ref(false);
const isPanelOpen = ref(false);
const selectedSkillKey = ref('');

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
const isTopPlacement = computed(() => props.placement === 'top');
const isDrawerResult = computed(() => props.resultPlacement === 'drawer');
const selectedSkill = computed(
  () =>
    skills.value.find(skill => skill.key === activeSkill.value) ||
    skills.value.find(skill => skill.key === selectedSkillKey.value)
);
const menuPositionClass = computed(() =>
  isTopPlacement.value ? 'right-0 top-full mt-2' : 'bottom-full left-0 mb-2'
);
const panelPositionClass = computed(() => {
  if (isDrawerResult.value) {
    return 'fixed inset-y-3 right-3 z-50 flex w-[min(28rem,calc(100vw-1.5rem))] flex-col !shadow-none sm:inset-y-5 sm:right-5';
  }
  if (isTopPlacement.value) return 'absolute right-0 top-full z-40 mt-2 w-80';

  return 'mt-3';
});

const generate = async skill => {
  activeSkill.value = skill.key;
  selectedSkillKey.value = skill.key;
  isMenuOpen.value = false;
  isPanelOpen.value = true;
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
  isPanelOpen.value = false;
  suggestion.value = '';
  error.value = '';
  selectedSkillKey.value = '';
};
</script>

<template>
  <div class="relative" :class="{ 'mt-3': !isTopPlacement }">
    <Button
      icon="i-lucide-sparkles"
      :label="$t('TLIN_COPILOT.TRIGGER')"
      size="sm"
      :disabled="disabled"
      @click="isMenuOpen = !isMenuOpen"
    />

    <div
      v-if="isMenuOpen"
      class="absolute z-40 w-80 rounded-2xl border border-n-weak bg-n-solid-1 p-2 shadow-xl shadow-black/20"
      :class="menuPositionClass"
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

    <aside
      v-if="isPanelOpen"
      class="rounded-2xl border border-n-weak bg-n-solid-1 p-4 shadow-lg shadow-black/10"
      :class="panelPositionClass"
    >
      <div class="flex items-center justify-between gap-3">
        <div
          class="flex items-center gap-2 text-sm font-semibold text-n-slate-12"
        >
          <span
            class="i-lucide-sparkles size-4 text-n-brand"
            aria-hidden="true"
          />
          {{ selectedSkill?.label || $t('TLIN_COPILOT.TITLE') }}
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

      <div class="mt-3 min-h-0 flex-1 overflow-y-auto pr-1">
        <div
          v-if="isThinking"
          class="flex items-center gap-2 text-sm text-n-slate-11"
        >
          <span
            class="i-lucide-loader-circle size-4 animate-spin"
            aria-hidden="true"
          />
          {{ $t('TLIN_COPILOT.THINKING') }}
        </div>
        <p v-else-if="error" class="text-sm text-n-ruby-11">{{ error }}</p>
        <template v-else>
          <p class="whitespace-pre-wrap text-sm leading-6 text-n-slate-12">
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
    </aside>
  </div>
</template>
