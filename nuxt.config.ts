export default defineNuxtConfig({
  compatibilityDate: '2025-07-01',
  devtools: { enabled: false },
  css: ['~/assets/css/main.css'],
  runtimeConfig: {
    supabaseServiceRoleKey: '',
    public: {
      supabaseUrl: '',
      supabaseAnonKey: '',
      siteUrl: 'http://localhost:3000'
    }
  },
  nitro: {
    preset: 'cloudflare_module',
    cloudflare: { deployConfig: true, nodeCompat: true }
  },
  app: {
    head: {
      title: 'Community Directory',
      meta: [
        { name: 'description', content: 'Discover community members and public profiles.' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' }
      ]
    }
  },
  typescript: { strict: true }
})