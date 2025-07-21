import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/services/supabase'
import { queryKeys } from '@/services/queryClient'
import type { Event } from '@/types/database'

// Hook for fetching all events
export function useEvents() {
  return useQuery({
    queryKey: queryKeys.events,
    queryFn: async (): Promise<Event[]> => {
      const { data, error } = await supabase
        .from('events')
        .select('*')
        .order('date', { ascending: false })

      if (error) throw error
      return data || []
    },
    staleTime: 5 * 60 * 1000, // 5 minutes - events don't change frequently
  })
}

// Hook for fetching single event with details
export function useEvent(eventId: string) {
  return useQuery({
    queryKey: queryKeys.event(eventId),
    queryFn: async (): Promise<Event> => {
      const { data, error } = await supabase
        .from('events')
        .select(`
          *,
          event_players(
            id,
            name,
            email,
            phone
          )
        `)
        .eq('id', eventId)
        .single()

      if (error) throw error
      return data
    },
    enabled: !!eventId,
  })
}

// Hook for creating new events (admin only)
export function useCreateEvent() {
  const queryClient = useQueryClient()
  
  return useMutation({
    mutationFn: async (eventData: Partial<Event>) => {
      const { data, error } = await supabase
        .from('events')
        .insert([eventData])
        .select()
        .single()

      if (error) throw error
      return data
    },
    onSuccess: () => {
      // Invalidate events list to show new event
      queryClient.invalidateQueries({ queryKey: queryKeys.events })
    },
  })
}

// Hook for updating events (admin only)
export function useUpdateEvent() {
  const queryClient = useQueryClient()
  
  return useMutation({
    mutationFn: async ({ eventId, updates }: { eventId: string; updates: Partial<Event> }) => {
      const { data, error } = await supabase
        .from('events')
        .update(updates)
        .eq('id', eventId)
        .select()
        .single()

      if (error) throw error
      return data
    },
    onSuccess: (data) => {
      // Invalidate all related queries for this event
      queryClient.invalidateQueries({ queryKey: queryKeys.events })
      queryClient.invalidateQueries({ queryKey: queryKeys.event(data.id) })
    },
  })
}

// Hook for deleting events (admin only)  
export function useDeleteEvent() {
  const queryClient = useQueryClient()
  
  return useMutation({
    mutationFn: async (eventId: string) => {
      const { error } = await supabase
        .from('events')
        .delete()
        .eq('id', eventId)

      if (error) throw error
      return eventId
    },
    onSuccess: () => {
      // Invalidate events list to remove deleted event
      queryClient.invalidateQueries({ queryKey: queryKeys.events })
    },
  })
}