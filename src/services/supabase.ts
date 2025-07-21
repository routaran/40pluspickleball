import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY

// For demo/development builds without credentials, create a mock client
const isDemo = !supabaseUrl || !supabaseKey

if (isDemo) {
  console.warn('⚠️ Running in demo mode - Supabase credentials not configured')
  console.warn('Authentication and database features will show demo content')
}

// Use demo values if environment variables aren't set
const url = supabaseUrl || 'https://demo.supabase.co'
const key = supabaseKey || 'demo-key'

export const supabase = createClient(url, key, {
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

// Export demo flag for components to show appropriate demo content
export { isDemo }

// Export types for use throughout the application
export type { Database } from '@/types/database'