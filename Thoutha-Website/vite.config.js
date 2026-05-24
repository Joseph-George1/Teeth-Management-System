import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'
import fs from 'fs'
import path from 'path'

const API_TARGET = 'https://thoutha.page'

function firebaseSWPlugin() {
  return {
    name: 'firebase-sw-compiler',
    configResolved(config) {
      const env = loadEnv(config.mode, config.root)
      const templatePath = path.resolve(config.root, 'public/firebase-messaging-sw.template.js')
      const outputPath = path.resolve(config.root, 'public/firebase-messaging-sw.js')
      
      if (fs.existsSync(templatePath)) {
        let content = fs.readFileSync(templatePath, 'utf8')
        content = content
          .replace('API_KEY_PLACEHOLDER', env.VITE_FIREBASE_API_KEY || '')
          .replace('AUTH_DOMAIN_PLACEHOLDER', env.VITE_FIREBASE_AUTH_DOMAIN || '')
          .replace('PROJECT_ID_PLACEHOLDER', env.VITE_FIREBASE_PROJECT_ID || '')
          .replace('STORAGE_BUCKET_PLACEHOLDER', env.VITE_FIREBASE_STORAGE_BUCKET || '')
          .replace('SENDER_ID_PLACEHOLDER', env.VITE_FIREBASE_MESSAGING_SENDER_ID || '')
          .replace('APP_ID_PLACEHOLDER', env.VITE_FIREBASE_APP_ID || '')
          
        fs.writeFileSync(outputPath, content, 'utf8')
        console.log('\n[Vite] Generated public/firebase-messaging-sw.js from template with environment variables.')
      } else {
        console.warn('\n[Vite] Warning: public/firebase-messaging-sw.template.js not found!')
      }
    }
  }
}

export default defineConfig({
  plugins: [
    react(),
    firebaseSWPlugin(),
    VitePWA({
      registerType: 'autoUpdate',
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,jpg,jpeg,webp}'],
        navigateFallbackDenylist: [/^\/firebase-messaging-sw\.js$/],
        importScripts: ['/firebase-messaging-sw.js'],
      },
      includeAssets: ['ثوثة.png', 'thoutha-48x48.png', 'thoutha-120x120.png', 'thoutha-152x152.png', 'thoutha-180x180.png'],
      manifest: {
        name: 'ثوثة - منصة حجز الأسنان',
        short_name: 'ثوثة',
        description: 'منصة ثوثة بتربط مرضى الأسنان بطلاب كليات طب الأسنان',
        theme_color: '#1e8a7a',
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
