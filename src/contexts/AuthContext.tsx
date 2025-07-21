import { createContext, useContext, useEffect, useState } from 'react'
import type { ReactNode } from 'react'
import type { User as SupabaseUser, Session, AuthError } from '@supabase/supabase-js'
import { supabase, isDemo } from '@/services/supabase'
import type { User } from '@/types/database'

// AuthState interface as specified in authentication-flow.md
interface AuthState {
  user: User | null
  session: Session | null
  loading: boolean
  initialized: boolean
  passwordSet: boolean
  sessionTimeRemaining: number // milliseconds
  deviceTrusted: boolean // "Remember me" status
}

interface AuthContextType extends AuthState {
  signInWithEmail: (email: string, password: string) => Promise<{ error: AuthError | null }>
  signUpWithEmail: (email: string, displayName: string) => Promise<{ error: AuthError | null }>
  signInWithMagicLink: (email: string) => Promise<{ error: AuthError | null }>
  setupPassword: (password: string) => Promise<{ error: AuthError | null }>
  signOut: () => Promise<{ error: AuthError | null }>
  refreshSession: () => Promise<void>
  setRememberMe: (remember: boolean) => void
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

interface AuthProviderProps {
  children: ReactNode
}

export function AuthProvider({ children }: AuthProviderProps) {
  const [authState, setAuthState] = useState<AuthState>({
    user: null,
    session: null,
    loading: true,
    initialized: false,
    passwordSet: false,
    sessionTimeRemaining: 0,
    deviceTrusted: false,
  })

  // Calculate session time remaining
  const calculateSessionTimeRemaining = (session: Session | null): number => {
    if (!session?.expires_at) return 0
    const expiryTime = new Date(session.expires_at * 1000).getTime()
    const currentTime = Date.now()
    return Math.max(0, expiryTime - currentTime)
  }

  // Check if device is trusted (remember me is enabled)
  const checkDeviceTrusted = (): boolean => {
    return localStorage.getItem('40plus-pickleball-remember-me') === 'true'
  }

  // Fetch user profile from our users table
  const fetchUserProfile = async (authUser: SupabaseUser): Promise<User | null> => {
    try {
      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('auth_id', authUser.id)
        .single()

      if (error) {
        console.error('Error fetching user profile:', error)
        return null
      }

      return data
    } catch (error) {
      console.error('Error in fetchUserProfile:', error)
      return null
    }
  }

  // Initialize authentication state
  useEffect(() => {
    let mounted = true
    let sessionInterval: NodeJS.Timeout

    const initializeAuth = async () => {
      try {
        // Handle demo mode - skip authentication
        if (isDemo) {
          setAuthState(prev => ({ 
            ...prev, 
            initialized: true, 
            loading: false 
          }))
          return
        }

        // Get initial session
        const { data: { session }, error } = await supabase.auth.getSession()
        
        if (error) {
          console.error('Error getting session:', error)
        }

        let userProfile: User | null = null
        
        if (session?.user) {
          userProfile = await fetchUserProfile(session.user)
        }

        if (mounted) {
          setAuthState({
            user: userProfile,
            session,
            loading: false,
            initialized: true,
            passwordSet: userProfile?.password_set || false,
            sessionTimeRemaining: calculateSessionTimeRemaining(session),
            deviceTrusted: checkDeviceTrusted(),
          })

          // Setup session refresh timer
          if (session) {
            sessionInterval = setInterval(() => {
              const timeRemaining = calculateSessionTimeRemaining(session)
              setAuthState(prev => ({
                ...prev,
                sessionTimeRemaining: timeRemaining
              }))

              // Auto-refresh when < 1 hour remaining (as per specification)
              if (timeRemaining < 60 * 60 * 1000 && timeRemaining > 0) {
                refreshSession()
              }
            }, 60000) // Check every minute
          }
        }
      } catch (error) {
        console.error('Error initializing auth:', error)
        if (mounted) {
          setAuthState(prev => ({
            ...prev,
            loading: false,
            initialized: true
          }))
        }
      }
    }

    initializeAuth()

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (!mounted) return

        let userProfile: User | null = null
        
        if (session?.user) {
          userProfile = await fetchUserProfile(session.user)
        }

        setAuthState(prev => ({
          ...prev,
          user: userProfile,
          session,
          passwordSet: userProfile?.password_set || false,
          sessionTimeRemaining: calculateSessionTimeRemaining(session),
          loading: false,
        }))

        // Handle password setup completion
        if (event === 'PASSWORD_RECOVERY') {
          // User needs to set up password after magic link
          setAuthState(prev => ({ ...prev, passwordSet: false }))
        }
      }
    )

    return () => {
      mounted = false
      subscription.unsubscribe()
      if (sessionInterval) {
        clearInterval(sessionInterval)
      }
    }
  }, [])

  // Sign in with email and password
  const signInWithEmail = async (email: string, password: string) => {
    setAuthState(prev => ({ ...prev, loading: true }))
    
    // Handle demo mode
    if (isDemo) {
      setAuthState(prev => ({ ...prev, loading: false }))
      return { error: { message: 'Demo mode - authentication not available' } as AuthError }
    }
    
    try {
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password,
      })

      return { error }
    } catch (error) {
      return { error: error as AuthError }
    }
  }

  // Sign up with email (creates user in auth and sends magic link)
  const signUpWithEmail = async (email: string, displayName: string) => {
    setAuthState(prev => ({ ...prev, loading: true }))
    
    // Handle demo mode
    if (isDemo) {
      setAuthState(prev => ({ ...prev, loading: false }))
      return { error: { message: 'Demo mode - registration not available' } as AuthError }
    }
    
    try {
      // First, create the auth user and send magic link
      const { data, error } = await supabase.auth.signUp({
        email,
        password: 'temporary-password', // Will be replaced during password setup
        options: {
          data: {
            display_name: displayName,
          }
        }
      })

      if (error) return { error }

      // If successful, create user profile in our users table
      if (data.user) {
        const { error: profileError } = await supabase
          .from('users')
          .insert({
            auth_id: data.user.id,
            email,
            display_name: displayName,
            role: 'organizer',
            password_set: false,
          })

        if (profileError) {
          console.error('Error creating user profile:', profileError)
          // Don't return error here as auth user is created successfully
        }
      }

      return { error: null }
    } catch (error) {
      return { error: error as AuthError }
    }
  }

  // Send magic link for existing users who haven't set password
  const signInWithMagicLink = async (email: string) => {
    setAuthState(prev => ({ ...prev, loading: true }))
    
    // Handle demo mode
    if (isDemo) {
      setAuthState(prev => ({ ...prev, loading: false }))
      return { error: { message: 'Demo mode - magic link not available' } as AuthError }
    }
    
    try {
      const { error } = await supabase.auth.signInWithOtp({
        email,
        options: {
          shouldCreateUser: false, // Only for existing users
        }
      })

      return { error }
    } catch (error) {
      return { error: error as AuthError }
    }
  }

  // Setup password after magic link authentication
  const setupPassword = async (password: string) => {
    try {
      const { error } = await supabase.auth.updateUser({
        password
      })

      if (error) return { error }

      // Update user profile to mark password as set
      const { error: updateError } = await supabase
        .from('users')
        .update({ password_set: true })
        .eq('auth_id', authState.session?.user?.id)

      if (updateError) {
        console.error('Error updating password_set flag:', updateError)
      }

      setAuthState(prev => ({ ...prev, passwordSet: true }))
      return { error: null }
    } catch (error) {
      return { error: error as AuthError }
    }
  }

  // Sign out
  const signOut = async () => {
    try {
      const { error } = await supabase.auth.signOut()
      
      // Clear remember me setting
      localStorage.removeItem('40plus-pickleball-remember-me')
      
      setAuthState({
        user: null,
        session: null,
        loading: false,
        initialized: true,
        passwordSet: false,
        sessionTimeRemaining: 0,
        deviceTrusted: false,
      })

      return { error }
    } catch (error) {
      return { error: error as AuthError }
    }
  }

  // Refresh session
  const refreshSession = async () => {
    try {
      const { data, error } = await supabase.auth.refreshSession()
      
      if (error) {
        console.error('Error refreshing session:', error)
        return
      }

      if (data.session) {
        setAuthState(prev => ({
          ...prev,
          session: data.session,
          sessionTimeRemaining: calculateSessionTimeRemaining(data.session),
        }))
      }
    } catch (error) {
      console.error('Error in refreshSession:', error)
    }
  }

  // Set remember me preference
  const setRememberMe = (remember: boolean) => {
    if (remember) {
      localStorage.setItem('40plus-pickleball-remember-me', 'true')
    } else {
      localStorage.removeItem('40plus-pickleball-remember-me')
    }
    
    setAuthState(prev => ({ ...prev, deviceTrusted: remember }))
  }

  const contextValue: AuthContextType = {
    ...authState,
    signInWithEmail,
    signUpWithEmail,
    signInWithMagicLink,
    setupPassword,
    signOut,
    refreshSession,
    setRememberMe,
  }

  return (
    <AuthContext.Provider value={contextValue}>
      {children}
    </AuthContext.Provider>
  )
}

// Hook to use auth context
export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}

// Additional hooks for convenience
export function useLogin() {
  const { signInWithEmail, signUpWithEmail, signInWithMagicLink } = useAuth()
  return { signInWithEmail, signUpWithEmail, signInWithMagicLink }
}

export function useLogout() {
  const { signOut } = useAuth()
  return signOut
}