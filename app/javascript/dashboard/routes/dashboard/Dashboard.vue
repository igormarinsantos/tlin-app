<script>
import { defineAsyncComponent, ref, computed } from 'vue';

import NextSidebar from 'next/sidebar/Sidebar.vue';
import WootKeyShortcutModal from 'dashboard/components/widgets/modal/WootKeyShortcutModal.vue';
import AddAccountModal from 'dashboard/components/app/AddAccountModal.vue';
import UpgradePage from 'dashboard/routes/dashboard/upgrade/UpgradePage.vue';

import { useUISettings } from 'dashboard/composables/useUISettings';
import { useAccount } from 'dashboard/composables/useAccount';
import { useWindowSize } from '@vueuse/core';

import wootConstants from 'dashboard/constants/globals';

const CommandBar = defineAsyncComponent(
  () => import('./commands/commandbar.vue')
);

const FloatingCallWidget = defineAsyncComponent(
  () => import('dashboard/components-next/call/FloatingCallWidget.vue')
);

import CopilotLauncher from 'dashboard/components-next/copilot/CopilotLauncher.vue';
import CopilotContainer from 'dashboard/components/copilot/CopilotContainer.vue';

import MobileSidebarLauncher from 'dashboard/components-next/sidebar/MobileSidebarLauncher.vue';
import TlinDialog from 'dashboard/components-next/dialog/Dialog.vue';
import { useCallsStore } from 'dashboard/stores/calls';
import { useMapGetter } from 'dashboard/composables/store';

export default {
  components: {
    NextSidebar,
    CommandBar,
    WootKeyShortcutModal,
    AddAccountModal,
    UpgradePage,
    CopilotLauncher,
    CopilotContainer,
    FloatingCallWidget,
    MobileSidebarLauncher,
    TlinDialog,
  },
  setup() {
    const upgradePageRef = ref(null);
    const { uiSettings, updateUISettings } = useUISettings();
    const { accountId } = useAccount();
    const currentUserId = useMapGetter('getCurrentUserID');
    const { width: windowWidth } = useWindowSize();
    const callsStore = useCallsStore();

    return {
      uiSettings,
      updateUISettings,
      accountId,
      currentUserId,
      upgradePageRef,
      windowWidth,
      hasActiveCall: computed(() => callsStore.hasActiveCall),
      hasIncomingCall: computed(() => callsStore.hasIncomingCall),
    };
  },
  data() {
    return {
      showAccountModal: false,
      showCreateAccountModal: false,
      showShortcutModal: false,
      isMobileSidebarOpen: false,
      dontShowTrialNotice: false,
      showTrialNotice: false,
    };
  },
  computed: {
    isSmallScreen() {
      return this.windowWidth < wootConstants.SMALL_SCREEN_BREAKPOINT;
    },
    showUpgradePage() {
      return this.upgradePageRef?.shouldShowUpgradePage;
    },
    bypassUpgradePage() {
      return [
        'billing_settings_index',
        'settings_inbox_list',
        'general_settings_index',
        'agent_list',
      ].includes(this.$route.name);
    },
    previouslyUsedDisplayType() {
      const {
        previously_used_conversation_display_type: conversationDisplayType,
      } = this.uiSettings;
      return conversationDisplayType;
    },
    currentAccount() {
      return this.$store.getters['accounts/getAccount'](this.accountId);
    },
    trialDaysRemaining() {
      const attributes = this.currentAccount?.custom_attributes || {};
      const trialEndsAt = attributes.trial_ends_at;
      if (!trialEndsAt || attributes.plan_active) return null;

      return Math.max(
        0,
        Math.ceil((new Date(trialEndsAt) - new Date()) / 86400000)
      );
    },
    isTrialActive() {
      const attributes = this.currentAccount?.custom_attributes || {};
      const trialEndsAt = attributes.trial_ends_at;
      return (
        !attributes.plan_active &&
        trialEndsAt &&
        new Date(trialEndsAt) > new Date()
      );
    },
    trialNoticeStorageKey() {
      if (!this.accountId || !this.currentUserId) return null;

      return `tlin.trial-notice.hidden.${this.accountId}.${this.currentUserId}`;
    },
  },
  watch: {
    isTrialActive: {
      handler(isTrialActive) {
        if (isTrialActive) this.openTrialNotice();
      },
      immediate: true,
    },
    isSmallScreen: {
      handler() {
        const { LAYOUT_TYPES } = wootConstants;
        if (window.innerWidth <= wootConstants.SMALL_SCREEN_BREAKPOINT) {
          this.updateUISettings({
            conversation_display_type: LAYOUT_TYPES.EXPANDED,
          });
        } else {
          this.updateUISettings({
            conversation_display_type: this.previouslyUsedDisplayType,
          });
        }
      },
      immediate: true,
    },
  },
  methods: {
    toggleMobileSidebar() {
      this.isMobileSidebarOpen = !this.isMobileSidebarOpen;
    },
    closeMobileSidebar() {
      this.isMobileSidebarOpen = false;
    },
    openCreateAccountModal() {
      this.showAccountModal = false;
      this.showCreateAccountModal = true;
    },
    closeCreateAccountModal() {
      this.showCreateAccountModal = false;
    },
    toggleAccountModal() {
      this.showAccountModal = !this.showAccountModal;
    },
    toggleKeyShortcutModal() {
      this.showShortcutModal = true;
    },
    closeKeyShortcutModal() {
      this.showShortcutModal = false;
    },
    openTrialNotice() {
      if (
        !this.trialNoticeStorageKey ||
        window.localStorage.getItem(this.trialNoticeStorageKey)
      ) {
        return;
      }

      this.showTrialNotice = true;
      this.$nextTick(() => this.$refs.trialNoticeDialog?.open());
    },
    closeTrialNotice() {
      this.showTrialNotice = false;
    },
    confirmTrialNotice() {
      if (this.dontShowTrialNotice && this.trialNoticeStorageKey) {
        window.localStorage.setItem(this.trialNoticeStorageKey, 'true');
      }
      this.$refs.trialNoticeDialog?.close();
    },
  },
};
</script>

<template>
  <div class="flex flex-grow overflow-hidden text-n-slate-12">
    <NextSidebar
      :is-mobile-sidebar-open="isMobileSidebarOpen"
      @toggle-account-modal="toggleAccountModal"
      @open-key-shortcut-modal="toggleKeyShortcutModal"
      @close-key-shortcut-modal="closeKeyShortcutModal"
      @show-create-account-modal="openCreateAccountModal"
      @close-mobile-sidebar="closeMobileSidebar"
    />

    <main
      class="relative flex flex-1 h-full w-full min-h-0 px-0 overflow-hidden bg-n-surface-1"
    >
      <UpgradePage
        v-show="showUpgradePage"
        ref="upgradePageRef"
        :bypass-upgrade-page="bypassUpgradePage"
      >
        <MobileSidebarLauncher
          :is-mobile-sidebar-open="isMobileSidebarOpen"
          @toggle="toggleMobileSidebar"
        />
      </UpgradePage>
      <template v-if="!showUpgradePage">
        <div
          v-if="isTrialActive && trialDaysRemaining !== null"
          class="pointer-events-none absolute inset-x-0 top-3 z-20 flex justify-center px-4"
        >
          <div
            class="pointer-events-auto flex items-center gap-2 rounded-full border border-n-weak bg-n-solid-1/95 px-4 py-2 text-sm font-medium text-n-slate-12"
          >
            <span
              class="i-lucide-flask-conical inline-flex size-5 items-center justify-center rounded-full bg-tlin-gradient text-n-black"
              aria-hidden="true"
            />
            <span>
              {{
                $t('APP_GLOBAL.TLIN_TRIAL.MODE.BANNER', {
                  count: trialDaysRemaining,
                })
              }}
            </span>
          </div>
        </div>
        <router-view />
        <CommandBar />
        <CopilotLauncher />
        <MobileSidebarLauncher
          :is-mobile-sidebar-open="isMobileSidebarOpen"
          @toggle="toggleMobileSidebar"
        />
        <CopilotContainer />
        <FloatingCallWidget v-if="hasActiveCall || hasIncomingCall" />
      </template>
      <AddAccountModal
        :show="showCreateAccountModal"
        @close-account-create-modal="closeCreateAccountModal"
      />
      <WootKeyShortcutModal
        v-model:show="showShortcutModal"
        @close="closeKeyShortcutModal"
        @clickaway="closeKeyShortcutModal"
      />
      <TlinDialog
        v-if="showTrialNotice"
        ref="trialNoticeDialog"
        :title="$t('APP_GLOBAL.TLIN_TRIAL.MODE.TITLE')"
        :description="$t('APP_GLOBAL.TLIN_TRIAL.MODE.DESCRIPTION')"
        :confirm-button-label="$t('APP_GLOBAL.TLIN_TRIAL.MODE.CONTINUE')"
        :show-cancel-button="false"
        @close="closeTrialNotice"
        @confirm="confirmTrialNotice"
      >
        <label class="flex items-center gap-3 text-sm text-n-slate-11">
          <input
            v-model="dontShowTrialNotice"
            type="checkbox"
            class="size-4 rounded border-n-weak text-n-brand focus:ring-n-brand"
          />
          {{ $t('APP_GLOBAL.TLIN_TRIAL.MODE.DONT_SHOW_AGAIN') }}
        </label>
      </TlinDialog>
    </main>
  </div>
</template>
