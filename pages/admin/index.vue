<script setup lang="ts">
definePageMeta({ middleware: 'admin' })
const supabase = useSupabase()
const rows = ref<any[]>([])
const message = ref('')
async function load() {
  const { data, error } = await supabase.from('public_profiles')
    .select('id, display_name, city, status, created_at').order('created_at', { ascending: false })
  rows.value = data || []; if (error) message.value = error.message
}
async function setStatus(id: string, status: string) {
  const { error } = await supabase.from('public_profiles').update({ status }).eq('id', id)
  message.value = error ? error.message : 'Moderation status updated.'
  await load()
}
onMounted(load)
</script>
<template><main class="page-shell"><header class="topbar"><NuxtLink class="brand" to="/">Community<span>Directory</span></NuxtLink><NuxtLink to="/dashboard">Member dashboard</NuxtLink></header><section class="content"><div class="eyebrow">CONTROL CENTER</div><h1>Admin moderation</h1><p class="muted">Review public profile listing requests. Admin access is enforced by database RLS as well as this route guard.</p><p v-if="message" class="notice">{{ message }}</p><div class="table-wrap"><table><thead><tr><th>Name</th><th>City</th><th>Status</th><th>Actions</th></tr></thead><tbody><tr v-for="r in rows" :key="r.id"><td>{{ r.display_name }}</td><td>{{ r.city }}</td><td>{{ r.status }}</td><td><button class="text-button" @click="setStatus(r.id,'approved')">Approve</button><button class="text-button danger" @click="setStatus(r.id,'rejected')">Reject</button></td></tr></tbody></table></div></section></main></template>