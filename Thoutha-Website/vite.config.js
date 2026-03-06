import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
export default defineConfig({
  plugins: [react()],
  // server: {
  //   proxy: {
  //     '/api': {
  //       target: 'http://16.16.218.59:8080',
  //       changeOrigin: true,
  //       secure: false,
  //       configure: (proxy) => {
  //         proxy.on('proxyReq', (proxyReq) => {
  //           proxyReq.removeHeader('origin')
  //           proxyReq.removeHeader('referer')
  //         })
  //       }
  //     }
  //   }
  // }
})

