import { defineConfig } from 'vite'
import path from 'path'
import react from '@vitejs/plugin-react'
import { powerApps } from '@microsoft/power-apps-vite';

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    react(),
    powerApps()
  ],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  }
})
