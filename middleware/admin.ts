export default defineNuxtRouteMiddleware(async () => {
  if (import.meta.server) return
  const auth = useAuth()
  const user = await auth.refresh()
  if (!user) return navigateTo('/login')
  const { data, error } = await useSupabase()
    .from('user_roles').select('role').eq('user_id', user.id).maybeSingle()
  if (error || data?.role !== 'admin') return navigateTo('/dashboard')
})