import { createClient, type SupabaseClient } from '@supabase/supabase-js'

let client: SupabaseClient | null = null

export function useSupabase() {
  const config = useRuntimeConfig()
  if (!config.public.supabaseUrl || !config.public.supabaseAnonKey) {
    throw new Error('Supabase is not configured. Set NUXT_PUBLIC_SUPABASE_URL and NUXT_PUBLIC_SUPABASE_ANON_KEY.')
  }
  if (!client) {
    client = createClient(
      String(config.public.supabaseUrl),
      String(config.public.supabaseAnonKey),
      { auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true } }
    )
  }
  return client
}