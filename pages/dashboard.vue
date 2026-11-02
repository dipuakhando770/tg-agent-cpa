<script setup lang="ts">
definePageMeta({ middleware: 'auth' })
const supabase = useSupabase()
const auth = useAuth()
const profile = ref<any>({ display_name: '', bio: '', city: '', visibility: 'private' })
const message = ref('')
onMounted(async () => {
  const user = await auth.refresh()
  if (!user) return
  const { data } = await supabase.from('profiles').select('*').eq('id', user.id).maybeSingle()
  if (data) profile.value = data
})
async function save() {
  const user = await auth.refresh()
  if (!user) return
  const { error } = await supabase.from('profiles').upsert({
    id: user.id, display_name: profile.value.display_name,
    bio: profile.value.bio, city: profile.value.city,
    visibility: profile.value.visibility, updated_at: new Date().toISOString()
  })
  message.value = error ? error.message : 'Profile saved. Public listing requires admin approval.'
}
</script>
<template><main class="page-shell"><header class="topbar"><NuxtLink class="brand" to="/">Community<span>Directory</span></NuxtLink><button class="text-button" @click="auth.signOut">Sign out</button></header><section class="content narrow"><div class="eyebrow">YOUR ACCOUNT</div><h1>Member dashboard</h1><form class="panel" @submit.prevent="save"><label>Display name<input v-model="profile.display_name" maxlength="60" required /></label><label>Short bio<textarea v-model="profile.bio" maxlength="300" rows="4" /></label><label>City<input v-model="profile.city" maxlength="80" /></label><label>Profile visibility<select v-model="profile.visibility"><option value="private">Private</option><option value="public">Request public listing</option></select></label><p v-if="message" class="notice">{{ message }}</p><button class="button">Save profile</button></form></section></main></template>