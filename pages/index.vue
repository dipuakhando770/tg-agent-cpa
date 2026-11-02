<script setup lang="ts">
const supabase = useSupabase()
const query = ref('')
const profiles = ref<any[]>([])
const loading = ref(true)
const errorMessage = ref('')
async function search() {
  loading.value = true
  errorMessage.value = ''
  let request = supabase.from('public_profiles')
    .select('id, display_name, bio, city, avatar_url, created_at')
    .eq('status', 'approved').order('created_at', { ascending: false }).limit(24)
  if (query.value.trim()) request = request.or(`display_name.ilike.%${query.value.trim()}%,city.ilike.%${query.value.trim()}%`)
  const { data, error } = await request
  profiles.value = data || []
  if (error) errorMessage.value = error.message
  loading.value = false
}
onMounted(search)
useSeoMeta({ title: 'Community Directory', description: 'Discover public community profiles.' })
</script>

<template>
  <main class="page-shell">
    <header class="topbar">
      <NuxtLink class="brand" to="/">Community<span>Directory</span></NuxtLink>
      <nav><NuxtLink to="/login">Sign in</NuxtLink><NuxtLink class="button small" to="/register">Join community</NuxtLink></nav>
    </header>
    <section class="hero">
      <div class="eyebrow">A PLACE TO CONNECT</div>
      <h1>Discover your <span>community.</span></h1>
      <p>Explore public member profiles and find people with shared interests.</p>
      <form class="searchbar" @submit.prevent="search">
        <span>⌕</span><input v-model="query" aria-label="Search profiles" placeholder="Search by name or city..." />
        <button class="button" type="submit">Search</button>
      </form>
    </section>
    <section class="content">
      <div class="section-heading"><div><div class="eyebrow">COMMUNITY MEMBERS</div><h2>Recently joined</h2></div><span class="muted">Public profiles</span></div>
      <p v-if="errorMessage" class="notice">{{ errorMessage }} — Check Supabase setup and migrations.</p>
      <div v-if="loading" class="empty">Loading community…</div>
      <div v-else-if="!profiles.length" class="empty">No approved profiles yet. Create the first profile after configuring Supabase.</div>
      <div v-else class="profile-grid">
        <article v-for="profile in profiles" :key="profile.id" class="profile-card">
          <img v-if="profile.avatar_url" :src="profile.avatar_url" alt="" class="avatar" />
          <div v-else class="avatar placeholder">{{ profile.display_name?.slice(0,1)?.toUpperCase() || 'M' }}</div>
          <h3>{{ profile.display_name }}</h3><p>{{ profile.city || 'Community member' }}</p>
          <p class="bio">{{ profile.bio || 'A member of our community.' }}</p>
        </article>
      </div>
    </section>
    <footer>© {{ new Date().getFullYear() }} Community Directory · Respectful community, safer connections.</footer>
  </main>
</template>