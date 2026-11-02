<script setup lang="ts">
const { signIn, loading } = useAuth()
const email = ref(''), password = ref(''), message = ref('')
async function submit() {
  message.value = ''
  try { await signIn(email.value, password.value); await navigateTo('/dashboard') }
  catch (e: any) { message.value = e.message || 'Sign in failed.' }
}
</script>
<template><main class="auth-wrap"><NuxtLink class="brand" to="/">Community<span>Directory</span></NuxtLink><form class="panel" @submit.prevent="submit"><div class="eyebrow">WELCOME BACK</div><h1>Sign in</h1><label>Email<input v-model="email" type="email" required autocomplete="email" /></label><label>Password<input v-model="password" type="password" required autocomplete="current-password" /></label><p v-if="message" class="notice">{{ message }}</p><button class="button full" :disabled="loading">{{ loading ? 'Signing in…' : 'Sign in' }}</button><p class="muted">New here? <NuxtLink to="/register">Create an account</NuxtLink></p></form></main></template>