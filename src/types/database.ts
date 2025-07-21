export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      users: {
        Row: {
          id: string
          email: string
          display_name: string
          role: 'organizer' | 'admin'
          is_active: boolean
          auth_id: string | null
          password_set: boolean
          last_login: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          email: string
          display_name: string
          role?: 'organizer' | 'admin'
          is_active?: boolean
          auth_id?: string | null
          password_set?: boolean
          last_login?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          email?: string
          display_name?: string
          role?: 'organizer' | 'admin'
          is_active?: boolean
          auth_id?: string | null
          password_set?: boolean
          last_login?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      events: {
        Row: {
          id: string
          name: string
          event_date: string
          start_time: string | null
          created_by: string
          status: 'draft' | 'active' | 'completed' | 'cancelled'
          courts: Json
          scoring_format: Json
          max_players: number | null
          allow_mid_event_joins: boolean
          is_public: boolean
          timezone: string
          print_settings: Json
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          event_date: string
          start_time?: string | null
          created_by: string
          status?: 'draft' | 'active' | 'completed' | 'cancelled'
          courts?: Json
          scoring_format?: Json
          max_players?: number | null
          allow_mid_event_joins?: boolean
          is_public?: boolean
          timezone?: string
          print_settings?: Json
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          event_date?: string
          start_time?: string | null
          created_by?: string
          status?: 'draft' | 'active' | 'completed' | 'cancelled'
          courts?: Json
          scoring_format?: Json
          max_players?: number | null
          allow_mid_event_joins?: boolean
          is_public?: boolean
          timezone?: string
          print_settings?: Json
          created_at?: string
          updated_at?: string
        }
      }
      players: {
        Row: {
          id: string
          name: string
          email: string | null
          phone: string | null
          skill_level: string | null
          notes: string | null
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          email?: string | null
          phone?: string | null
          skill_level?: string | null
          notes?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          email?: string | null
          phone?: string | null
          skill_level?: string | null
          notes?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      event_players: {
        Row: {
          id: string
          event_id: string
          player_id: string
          check_out_time: string | null
          status: 'registered' | 'departed' | 'no_show'
          added_by: string | null
          joined_at_round: number
          last_bye_round: number | null
          total_bye_rounds: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          event_id: string
          player_id: string
          check_out_time?: string | null
          status?: 'registered' | 'departed' | 'no_show'
          added_by?: string | null
          joined_at_round?: number
          last_bye_round?: number | null
          total_bye_rounds?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          event_id?: string
          player_id?: string
          check_out_time?: string | null
          status?: 'registered' | 'departed' | 'no_show'
          added_by?: string | null
          joined_at_round?: number
          last_bye_round?: number | null
          total_bye_rounds?: number
          created_at?: string
          updated_at?: string
        }
      }
      rounds: {
        Row: {
          id: string
          event_id: string
          round_number: number
          status: 'pending' | 'active' | 'completed'
          started_at: string | null
          completed_at: string | null
          is_additional: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          event_id: string
          round_number: number
          status?: 'pending' | 'active' | 'completed'
          started_at?: string | null
          completed_at?: string | null
          is_additional?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          event_id?: string
          round_number?: number
          status?: 'pending' | 'active' | 'completed'
          started_at?: string | null
          completed_at?: string | null
          is_additional?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      matches: {
        Row: {
          id: string
          event_id: string
          round_id: string
          match_number: number
          court_assignment: string | null
          status: 'pending' | 'in_progress' | 'completed' | 'cancelled'
          is_bye: boolean
          scheduled_time: string | null
          started_at: string | null
          completed_at: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          event_id: string
          round_id: string
          match_number: number
          court_assignment?: string | null
          status?: 'pending' | 'in_progress' | 'completed' | 'cancelled'
          is_bye?: boolean
          scheduled_time?: string | null
          started_at?: string | null
          completed_at?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          event_id?: string
          round_id?: string
          match_number?: number
          court_assignment?: string | null
          status?: 'pending' | 'in_progress' | 'completed' | 'cancelled'
          is_bye?: boolean
          scheduled_time?: string | null
          started_at?: string | null
          completed_at?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      match_players: {
        Row: {
          id: string
          match_id: string
          player_id: string
          team: 1 | 2
          position: 1 | 2
          created_at: string
        }
        Insert: {
          id?: string
          match_id: string
          player_id: string
          team: 1 | 2
          position: 1 | 2
          created_at?: string
        }
        Update: {
          id?: string
          match_id?: string
          player_id?: string
          team?: 1 | 2
          position?: 1 | 2
          created_at?: string
        }
      }
      match_scores: {
        Row: {
          id: string
          match_id: string
          team1_score: number
          team2_score: number
          winning_team: 1 | 2 | null
          duration_minutes: number | null
          notes: string | null
          recorded_by: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          match_id: string
          team1_score: number
          team2_score: number
          winning_team?: 1 | 2 | null
          duration_minutes?: number | null
          notes?: string | null
          recorded_by?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          match_id?: string
          team1_score?: number
          team2_score?: number
          winning_team?: 1 | 2 | null
          duration_minutes?: number | null
          notes?: string | null
          recorded_by?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      player_statistics: {
        Row: {
          player_id: string
          total_events: number
          total_matches: number
          total_wins: number
          total_losses: number
          total_points_for: number
          total_points_against: number
          win_percentage: number
          avg_point_differential: number
          last_event_date: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          player_id: string
          total_events?: number
          total_matches?: number
          total_wins?: number
          total_losses?: number
          total_points_for?: number
          total_points_against?: number
          last_event_date?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          player_id?: string
          total_events?: number
          total_matches?: number
          total_wins?: number
          total_losses?: number
          total_points_for?: number
          total_points_against?: number
          last_event_date?: string | null
          created_at?: string
          updated_at?: string
        }
      }
    }
    Views: {
      public_events: {
        Row: {
          id: string
          name: string
          event_date: string
          start_time: string | null
          status: 'draft' | 'active' | 'completed' | 'cancelled'
          courts: Json
          scoring_format: Json
          max_players: number | null
          allow_mid_event_joins: boolean
          is_public: boolean
          timezone: string
          print_settings: Json
          created_at: string
          updated_at: string
          organizer_name: string
        }
      }
      active_events: {
        Row: {
          id: string
          name: string
          event_date: string
          start_time: string | null
          created_by: string
          status: 'draft' | 'active' | 'completed' | 'cancelled'
          courts: Json
          scoring_format: Json
          max_players: number | null
          allow_mid_event_joins: boolean
          is_public: boolean
          timezone: string
          print_settings: Json
          created_at: string
          updated_at: string
          organizer_name: string
          player_count: number
          court_count: number
        }
      }
      match_details: {
        Row: {
          id: string
          event_id: string
          round_id: string
          match_number: number
          court_assignment: string | null
          status: 'pending' | 'in_progress' | 'completed' | 'cancelled'
          is_bye: boolean
          scheduled_time: string | null
          started_at: string | null
          completed_at: string | null
          created_at: string
          updated_at: string
          event_name: string
          round_number: number
          team1_players: string | null
          team2_players: string | null
          team1_score: number | null
          team2_score: number | null
          winning_team: 1 | 2 | null
        }
      }
      player_standings: {
        Row: {
          event_id: string
          player_id: string
          player_name: string
          joined_at_round: number
          matches_played: number
          wins: number
          losses: number
          points_for: number
          points_against: number
          win_percentage: number | null
          point_differential: number
          ranking: number
        }
      }
    }
    Functions: {
      get_current_round: {
        Args: {
          event_id_param: string
        }
        Returns: {
          round_id: string
          round_number: number
        }[]
      }
      is_round_complete: {
        Args: {
          round_id_param: string
        }
        Returns: boolean
      }
      get_head_to_head_winner: {
        Args: {
          player1_id: string
          player2_id: string
          event_id_param: string
        }
        Returns: number
      }
    }
    Enums: {
      [_ in never]: never
    }
  }
}

// Helper types for application use
export type User = Database['public']['Tables']['users']['Row']
export type Event = Database['public']['Tables']['events']['Row']
export type Player = Database['public']['Tables']['players']['Row']
export type EventPlayer = Database['public']['Tables']['event_players']['Row']
export type Round = Database['public']['Tables']['rounds']['Row']
export type Match = Database['public']['Tables']['matches']['Row']
export type MatchPlayer = Database['public']['Tables']['match_players']['Row']
export type MatchScore = Database['public']['Tables']['match_scores']['Row']
export type PlayerStatistics = Database['public']['Tables']['player_statistics']['Row']

export type PublicEvent = Database['public']['Views']['public_events']['Row']
export type ActiveEvent = Database['public']['Views']['active_events']['Row']
export type MatchDetail = Database['public']['Views']['match_details']['Row']
export type PlayerStanding = Database['public']['Views']['player_standings']['Row']

// Insert types
export type UserInsert = Database['public']['Tables']['users']['Insert']
export type EventInsert = Database['public']['Tables']['events']['Insert']
export type PlayerInsert = Database['public']['Tables']['players']['Insert']
export type EventPlayerInsert = Database['public']['Tables']['event_players']['Insert']
export type RoundInsert = Database['public']['Tables']['rounds']['Insert']
export type MatchInsert = Database['public']['Tables']['matches']['Insert']
export type MatchPlayerInsert = Database['public']['Tables']['match_players']['Insert']
export type MatchScoreInsert = Database['public']['Tables']['match_scores']['Insert']

// Update types
export type UserUpdate = Database['public']['Tables']['users']['Update']
export type EventUpdate = Database['public']['Tables']['events']['Update']
export type PlayerUpdate = Database['public']['Tables']['players']['Update']
export type EventPlayerUpdate = Database['public']['Tables']['event_players']['Update']
export type RoundUpdate = Database['public']['Tables']['rounds']['Update']
export type MatchUpdate = Database['public']['Tables']['matches']['Update']
export type MatchPlayerUpdate = Database['public']['Tables']['match_players']['Update']
export type MatchScoreUpdate = Database['public']['Tables']['match_scores']['Update']

// Enums for type safety
export type UserRole = 'organizer' | 'admin'
export type EventStatus = 'draft' | 'active' | 'completed' | 'cancelled'
export type EventPlayerStatus = 'registered' | 'departed' | 'no_show'
export type RoundStatus = 'pending' | 'active' | 'completed'
export type MatchStatus = 'pending' | 'in_progress' | 'completed' | 'cancelled'
export type Team = 1 | 2
export type Position = 1 | 2

// Scoring configuration types
export interface ScoringFormat {
  games_to: number
  win_by: number
  match_format: string
}

// Court configuration types
export type CourtConfiguration = string[]

// Print settings types
export interface PrintSettings {
  courts_per_page: number
  font_size: string
  orientation: 'landscape' | 'portrait'
}