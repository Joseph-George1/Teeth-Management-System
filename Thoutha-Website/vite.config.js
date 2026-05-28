import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

const API_TARGET = 'https://thoutha.page'

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,jpg,jpeg,webp}'],
      },
      includeAssets: ['ثوثة.png', 'thoutha-48x48.png', 'thoutha-120x120.png', 'thoutha-152x152.png', 'thoutha-180x180.png'],
      manifest: {
        name: 'ثوثة - منصة حجز الأسنان',
        short_name: 'ثوثة',
        description: 'منصة ثوثة بتربط مرضى الأسنان بطلاب كليات طب الأسنان',
        background_color: '#ffffff',
        display: 'standalone',
        dir: 'rtl',
        lang: 'ar',
        start_url: '/',
        scope: '/',
        orientation: 'portrait',
        categories: ['medical', 'health'],
        icons: [
          {
            src: '/thoutha-48x48.png',
            sizes: '48x48',
            type: 'image/png',
          },
          {
            src: '/thoutha-120x120.png',
            sizes: '120x120',
            type: 'image/png',
          },
          {
            src: '/thoutha-152x152.png',
            sizes: '152x152',
            type: 'image/png',
          },
          {
            src: '/thoutha-180x180.png',
            sizes: '180x180',
            type: 'image/png',
          },
          {
            src: '/ثوثة.png',
            sizes: '192x192',
            type: 'image/png',
          },
          {
            src: '/ثوثة.png',
            sizes: '512x512',
            type: 'image/png',
            purpose: 'any maskable',
          },
        ],
      },
    }),
  ],
  server: {
    proxy: {
      '/api': {
        target: API_TARGET,
        changeOrigin: true,
        secure: true,
      },
    },
  },
})
