import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [svelte()],
  build:{
    emptyOutDir:true,
    sourcemap: true,
    outDir:"../service/frontend"
  }
})
