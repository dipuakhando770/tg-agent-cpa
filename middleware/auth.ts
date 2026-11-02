export default defineNuxtRouteMiddleware(async () => {
  if (import.meta.server) return
  const auth = useAuth()
  const user = await auth.refresh()
  if (!user) return navigateTo('/login')
})