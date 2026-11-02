export function useAuth() {
  const supabase = useSupabase()
  const user = useState<any>('auth-user', () => null)
  const loading = useState<boolean>('auth-loading', () => false)

  async function refresh() {
    const { data } = await supabase.auth.getUser()
    user.value = data.user
    return data.user
  }
  async function signIn(email: string, password: string) {
    loading.value = true
    try {
      const result = await supabase.auth.signInWithPassword({ email, password })
      if (result.error) throw result.error
      user.value = result.data.user
      return result.data
    } finally { loading.value = false }
  }
  async function signUp(email: string, password: string, displayName: string) {
    loading.value = true
    try {
      const result = await supabase.auth.signUp({
        email, password,
        options: { data: { display_name: displayName } }
      })
      if (result.error) throw result.error
      return result.data
    } finally { loading.value = false }
  }
  async function signOut() {
    await supabase.auth.signOut()
    user.value = null
    await navigateTo('/')
  }
  return { user, loading, refresh, signIn, signUp, signOut }
}