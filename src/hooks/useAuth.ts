import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/services/supabase'
import { queryKeys } from '@/services/queryClient'

// Hook for getting current user profile
export function useProfile(userId?: string) {
  return useQuery({
    queryKey: queryKeys.profile(userId || ''),
    queryFn: async () => {
      if (!userId) return null
      
      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('auth_id', userId)
        .single()

      if (error) throw error
      return data
    },
    enabled: !!userId,
    staleTime: 10 * 60 * 1000, // 10 minutes - user profile doesn't change often
  })
}

// Hook for updating user profile
export function useUpdateProfile() {
  const queryClient = useQueryClient()
  
  return useMutation({
    mutationFn: async ({ userId, updates }: { userId: string; updates: any }) => {
      const { data, error } = await supabase
        .from('users')
        .update(updates)
        .eq('auth_id', userId)
        .select()
        .single()

      if (error) throw error
      return data
    },
    onSuccess: (data) => {
      // Update profile cache
      queryClient.setQueryData(queryKeys.profile(data.auth_id), data)
    },
  })
}

// Hook for password setup after magic link
export function useSetupPassword() {
  const queryClient = useQueryClient()
  
  return useMutation({
    mutationFn: async ({ password, displayName }: { password: string; displayName: string }) => {
      // Update password in Supabase Auth
      const { error: authError } = await supabase.auth.updateUser({
        password: password,
      })
      
      if (authError) throw authError

      // Update profile in database
      const { data: user } = await supabase.auth.getUser()
      if (!user.user) throw new Error('No user found')

      const { data, error } = await supabase
        .from('users')
        .update({ 
          password_set: true,
          display_name: displayName,
        })
        .eq('auth_id', user.user.id)
        .select()
        .single()

      if (error) throw error
      return data
    },
    onSuccess: (data) => {
      // Update profile cache
      queryClient.setQueryData(queryKeys.profile(data.auth_id), data)
      // Invalidate auth queries to refresh user state
      queryClient.invalidateQueries({ queryKey: queryKeys.auth })
    },
  })
}

// Hook for requesting magic link
export function useRequestMagicLink() {
  return useMutation({
    mutationFn: async (email: string) => {
      const { error } = await supabase.auth.signInWithOtp({
        email,
        options: {
          // Redirect to password setup after magic link verification
          emailRedirectTo: `${window.location.origin}/setup-password`,
        },
      })
      
      if (error) throw error
      return { success: true }
    },
  })
}

// Hook for email/password sign in
export function useSignIn() {
  const queryClient = useQueryClient()
  
  return useMutation({
    mutationFn: async ({ email, password }: { email: string; password: string }) => {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      })
      
      if (error) throw error
      return data
    },
    onSuccess: () => {
      // Invalidate auth queries to refresh user state
      queryClient.invalidateQueries({ queryKey: queryKeys.auth })
    },
  })
}

// Hook for sign out
export function useSignOut() {
  const queryClient = useQueryClient()
  
  return useMutation({
    mutationFn: async () => {
      const { error } = await supabase.auth.signOut()
      if (error) throw error
    },
    onSuccess: () => {
      // Clear all cached data on logout
      queryClient.clear()
    },
  })
}