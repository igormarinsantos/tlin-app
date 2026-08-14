import { defineConfig } from 'vite';
import ruby from 'vite-plugin-ruby';
import vue from '@vitejs/plugin-vue';
import { aliases, vueOptions } from './vite.shared';
import yaml from '@rollup/plugin-yaml';

export default defineConfig({
  plugins: [ruby(), vue(vueOptions), yaml()],
  // Rails serves the application on 3001 in the documented WSL workflow.
  // Vite remains a separate dev server on 3036, where the browser receives HMR.
  // These values apply only to `bin/vite dev`; production builds are unaffected.
  server: {
    host: '0.0.0.0',
    port: 3036,
    strictPort: true,
    hmr: {
      host: 'localhost',
      clientPort: 3036,
    },
  },
  css: {
    preprocessorOptions: {
      scss: {
        api: 'modern-compiler',
      },
    },
  },
  resolve: { alias: aliases },
});
