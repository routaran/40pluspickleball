import { QueryClient } from '@tanstack/react-query'

// Configure TanStack Query client optimized for real-time tournament management
export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      // Cache data for 5 minutes by default
      staleTime: 5 * 60 * 1000, // 5 minutes
      
      // Keep data in cache for 10 minutes after component unmounts
      gcTime: 10 * 60 * 1000, // 10 minutes (formerly cacheTime)
      
      // Retry failed requests 2 times with exponential backoff
      retry: 2,
      
      // Refetch on window focus for real-time updates during tournaments
      refetchOnWindowFocus: true,
      
      // Refetch when network reconnects (important for mobile courtside use)
      refetchOnReconnect: true,
      
      // Don't refetch on mount if data is still fresh (performance optimization)
      refetchOnMount: 'always',
    },
    mutations: {
      // Retry failed mutations once (important for score entry)
      retry: 1,
      
      // Show network errors to users for failed mutations
      onError: (error: any) => {
        console.error('Mutation error:', error)
        // TODO: Add toast notification system in Week 2
      },
    },
  },
})

// Query keys for consistent cache management
export const queryKeys = {
  // Authentication
  auth: ['auth'] as const,
  profile: (userId: string) => ['auth', 'profile', userId] as const,
  
  // Events
  events: ['events'] as const,
  event: (eventId: string) => ['events', eventId] as const,
  eventSchedule: (eventId: string) => ['events', eventId, 'schedule'] as const,
  eventStandings: (eventId: string) => ['events', eventId, 'standings'] as const,
  eventMatches: (eventId: string) => ['events', eventId, 'matches'] as const,
  
  // Players
  players: ['players'] as const,
  player: (playerId: string) => ['players', playerId] as const,
  playerStats: (playerId: string) => ['players', playerId, 'stats'] as const,
  
  // Real-time queries (shorter cache times)
  liveStandings: (eventId: string) => ['live', 'standings', eventId] as const,
  liveMatches: (eventId: string) => ['live', 'matches', eventId] as const,
  currentRound: (eventId: string) => ['live', 'round', eventId] as const,
} as const

// Helper function to invalidate related queries after mutations
export const invalidateQueries = {
  // Invalidate all event-related data when event changes
  event: (eventId: string) => {
    queryClient.invalidateQueries({ queryKey: queryKeys.event(eventId) })
    queryClient.invalidateQueries({ queryKey: queryKeys.eventSchedule(eventId) })
    queryClient.invalidateQueries({ queryKey: queryKeys.eventStandings(eventId) })
    queryClient.invalidateQueries({ queryKey: queryKeys.eventMatches(eventId) })
    queryClient.invalidateQueries({ queryKey: queryKeys.liveStandings(eventId) })
    queryClient.invalidateQueries({ queryKey: queryKeys.liveMatches(eventId) })
    queryClient.invalidateQueries({ queryKey: queryKeys.currentRound(eventId) })
  },
  
  // Invalidate all events when new event is created
  allEvents: () => {
    queryClient.invalidateQueries({ queryKey: queryKeys.events })
  },
  
  // Invalidate player data when stats change
  player: (playerId: string) => {
    queryClient.invalidateQueries({ queryKey: queryKeys.player(playerId) })
    queryClient.invalidateQueries({ queryKey: queryKeys.playerStats(playerId) })
  },
  
  // Invalidate all players when tournament results affect stats
  allPlayers: () => {
    queryClient.invalidateQueries({ queryKey: queryKeys.players })
  },
}

// Prefetch utilities for better performance
export const prefetchQueries = {
  // Prefetch event details when user hovers over event in list
  eventDetails: (eventId: string) => {
    queryClient.prefetchQuery({
      queryKey: queryKeys.event(eventId),
      staleTime: 2 * 60 * 1000, // 2 minutes
    })
  },
  
  // Prefetch standings for active events
  eventStandings: (eventId: string) => {
    queryClient.prefetchQuery({
      queryKey: queryKeys.eventStandings(eventId),
      staleTime: 1 * 60 * 1000, // 1 minute for real-time data
    })
  },
}

export default queryClient