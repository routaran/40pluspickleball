import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl) {
  throw new Error('Missing VITE_SUPABASE_URL environment variable')
}

if (!supabaseKey) {
  throw new Error('Missing VITE_SUPABASE_ANON_KEY environment variable')
}

export const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: {
    // Configure 30-day session duration as per PRD requirements
    storage: window.localStorage,
    storageKey: '40plus-pickleball-auth',
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true
  },
  // Configure for production use
  realtime: {
    params: {
      eventsPerSecond: 10,
    },
  },
})

// Export types for use throughout the application
export type { Database } from '@/types/database'