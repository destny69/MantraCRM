import { sentrySvelteKit } from "@sentry/sveltekit";
import tailwindcss from '@tailwindcss/vite';
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig, loadEnv } from 'vite';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  return {
    server: {
      allowedHosts: ['mantracrm.mantraideas.com.np'],
    },
    plugins: [sentrySvelteKit({
      org: "micropyramid-fa",
      project: "bottlecrm-app",
      sourceMapsUploadOptions: {
        authToken: env.SENTRY_AUTH_TOKEN
      },
      autoUploadSourceMaps: !!env.PUBLIC_SENTRY_DSN
    }), tailwindcss(), sveltekit()],
  };
});
