import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY

// For demo/development builds without credentials, create a mock client
const isDemo = !supabaseUrl || !supabaseKey

if (isDemo) {
  console.warn('⚠️ Running in demo mode - Supabase credentials not configured')
  console.warn('Authentication and database features will show demo content')
}

// Create a safe Supabase client that works in demo mode
let supabase: any

if (isDemo) {
  // Create a mock client for demo mode
  supabase = {
    auth: {
      getSession: () => Promise.resolve({ data: { session: null }, error: null }),
      getUser: () => Promise.resolve({ data: { user: null }, error: null }),
      signInWithPassword: () => Promise.resolve({ error: { message: 'Demo mode - authentication not available' } }),
      signInWithOtp: () => Promise.resolve({ error: { message: 'Demo mode - magic link not available' } }),
      signUp: () => Promise.resolve({ error: { message: 'Demo mode - registration not available' } }),
      signOut: () => Promise.resolve({ error: null }),
      updateUser: () => Promise.resolve({ error: { message: 'Demo mode - user updates not available' } }),
      onAuthStateChange: () => ({ data: { subscription: { unsubscribe: () => {} } } })
    },
    from: () => ({
      select: () => ({ 
        eq: () => ({ 
          single: () => Promise.resolve({ data: null, error: { message: 'Demo mode - database queries not available' } }) 
        }) 
      })
    })
  }
} else {
  // Use real Supabase client with actual credentials
  supabase = createClient(supabaseUrl, supabaseKey, {
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
}

export { supabase }

// Export demo flag for components to show appropriate demo content
export { isDemo }

// Export types for use throughout the application
export type { Database } from '@/types/database'