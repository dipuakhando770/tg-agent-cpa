<script setup lang="ts">
const { signUp, loading } = useAuth()
const name = ref(''), email = ref(''), password = ref(''), message = ref(''), success = ref(false)
async function submit() {
  message.value = ''; success.value = false
  if (password.value.length < 10) { message.value = 'Use a password with at least 10 characters.'; return }
  try { await signUp(email.value, password.value, name.value); success.value = true; message.value = 'Account created. Check your email if verification is enabled.' }
  catch (e: any) { message.value = e.message || 'Registration failed.' }
}
</script>
<template><main class="auth-wrap"><NuxtLink class="brand" to="/">Community<span>Directory</span></NuxtLink><form class="panel" @submit.prevent="submit"><div class="eyebrow">JOIN THE COMMUNITY</div><h1>Create account</h1><label>Display name<input v-model="name" required maxlength="60" /></label><label>Email<input v-model="email" type="email" required autocomplete="email" /></label><label>Password<input v-model="password" type="password" required minlength="10" autocomplete="new-password" /></label><p v-if="message" :class="success ? 'success notice' : 'notice'">{{ message }}</p><button class="button full" :disabled="loading">{{ loading ? 'Creating…' : 'Create account' }}</button><p class="muted">Already registered? <NuxtLink to="/login">Sign in</NuxtLink></p></form></main></template>