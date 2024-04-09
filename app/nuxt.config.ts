// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  css: ['reset-css'],
  app: {
    baseURL: '/ifv/',
  },
  vite: {
    css: {
      preprocessorOptions: {
        scss: {
          additionalData: '@import "@/assets/styles/_variables.scss";',
        },
      },
    },
  },
  runtimeConfig: {
    public: {
      API_URL: 'http://api.med2rdf.org/sparqlist/api'
    }
  }
})
