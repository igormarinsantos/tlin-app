import { frontendURL } from 'dashboard/helper/URLHelper';

import TlinAiAgent from './Index.vue';

export const routes = [
  {
    path: frontendURL('accounts/:accountId/ai-agent'),
    name: 'tlin_ai_agent',
    component: TlinAiAgent,
    meta: {
      permissions: ['administrator'],
    },
  },
];
