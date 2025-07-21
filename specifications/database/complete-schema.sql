-- Complete Database Schema for 40+ Pickleball Platform
-- Includes all tables, relationships, indexes, and RLS policies

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- USERS TABLE
-- =====================================================
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'organizer' CHECK (role IN ('organizer', 'admin')),
  password_set BOOLEAN DEFAULT FALSE,
  last_login TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- =====================================================
-- EVENTS TABLE
-- =====================================================
CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL CHECK (LENGTH(name) BETWEEN 5 AND 100),
  event_date DATE NOT NULL,
  start_time TIME NOT NULL,
  created_by UUID NOT NULL REFERENCES users(id),
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'completed', 'cancelled')),
  courts JSONB NOT NULL DEFAULT '[]'::jsonb,
  -- Court format: ["Court 1", "Court 2", "Court 3", "Court 4"]
  scoring_format JSONB NOT NULL DEFAULT '{
    "target_points": 11,
    "win_by_two": true,
    "games_per_match": 1
  }'::jsonb,
  -- Scoring format structure:
  -- {
  --   "target_points": 9 | 11 | 15,
  --   "win_by_two": boolean,
  --   "games_per_match": 1 | 3
  -- }
  max_players INTEGER DEFAULT 32 CHECK (max_players >= 4 AND max_players <= 32),
  allow_mid_event_joins BOOLEAN DEFAULT FALSE,
  timezone TEXT DEFAULT 'America/Edmonton',
  print_settings JSONB DEFAULT '{
    "schedule_orientation": "auto",
    "standings_per_page": 30,
    "include_court_assignments": true
  }'::jsonb,
  cancellation_reason TEXT,
  cancelled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for events
CREATE INDEX idx_events_created_by ON events(created_by);
CREATE INDEX idx_events_event_date ON events(event_date);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_date_status ON events(event_date, status);

-- =====================================================
-- PLAYERS TABLE
-- =====================================================
CREATE TABLE players (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL CHECK (LENGTH(name) BETWEEN 2 AND 50),
  email TEXT,
  phone TEXT,
  skill_level DECIMAL(2,1) CHECK (skill_level >= 2.5 AND skill_level <= 5.0),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  -- Ensure unique players based on name + contact info
  CONSTRAINT unique_player UNIQUE NULLS NOT DISTINCT (name, email, phone)
);

-- Indexes for players
CREATE INDEX idx_players_name ON players(LOWER(name));
CREATE INDEX idx_players_skill_level ON players(skill_level);

-- =====================================================
-- EVENT_PLAYERS TABLE (Junction)
-- =====================================================
CREATE TABLE event_players (
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  player_id UUID NOT NULL REFERENCES players(id),
  status TEXT NOT NULL DEFAULT 'registered' CHECK (status IN ('registered', 'present', 'departed', 'no_show')),
  check_in_time TIMESTAMPTZ,
  check_out_time TIMESTAMPTZ,
  joined_at_round INTEGER,
  last_bye_round INTEGER DEFAULT -1,
  total_bye_rounds INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (event_id, player_id)
);

-- Indexes for event_players
CREATE INDEX idx_event_players_event_id ON event_players(event_id);
CREATE INDEX idx_event_players_player_id ON event_players(player_id);
CREATE INDEX idx_event_players_status ON event_players(status);

-- =====================================================
-- ROUNDS TABLE
-- =====================================================
CREATE TABLE rounds (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  round_number INTEGER NOT NULL CHECK (round_number > 0),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'completed')),
  is_additional BOOLEAN DEFAULT FALSE,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_round_per_event UNIQUE (event_id, round_number)
);

-- Indexes for rounds
CREATE INDEX idx_rounds_event_id ON rounds(event_id);
CREATE INDEX idx_rounds_status ON rounds(status);
CREATE INDEX idx_rounds_event_status ON rounds(event_id, status);

-- =====================================================
-- MATCHES TABLE
-- =====================================================
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  round_id UUID NOT NULL REFERENCES rounds(id) ON DELETE CASCADE,
  match_number INTEGER NOT NULL CHECK (match_number > 0),
  court_assignment TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
  is_bye BOOLEAN DEFAULT FALSE,
  regenerated BOOLEAN DEFAULT FALSE,
  regenerated_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_match_per_round UNIQUE (round_id, match_number)
);

-- Indexes for matches
CREATE INDEX idx_matches_event_id ON matches(event_id);
CREATE INDEX idx_matches_round_id ON matches(round_id);
CREATE INDEX idx_matches_status ON matches(status);
CREATE INDEX idx_matches_court ON matches(court_assignment);
CREATE INDEX idx_matches_round_status ON matches(round_id, status);

-- =====================================================
-- MATCH_PLAYERS TABLE
-- =====================================================
CREATE TABLE match_players (
  match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  player_id UUID NOT NULL REFERENCES players(id),
  team INTEGER NOT NULL CHECK (team IN (1, 2)),
  position INTEGER NOT NULL CHECK (position IN (1, 2)),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  -- Ensure player appears only once per match
  CONSTRAINT unique_player_per_match UNIQUE (match_id, player_id),
  -- Ensure each position is filled only once per team
  CONSTRAINT unique_position_per_team UNIQUE (match_id, team, position),
  PRIMARY KEY (match_id, player_id)
);

-- Indexes for match_players
CREATE INDEX idx_match_players_match_id ON match_players(match_id);
CREATE INDEX idx_match_players_player_id ON match_players(player_id);
CREATE INDEX idx_match_players_team ON match_players(team);

-- =====================================================
-- MATCH_SCORES TABLE
-- =====================================================
CREATE TABLE match_scores (
  match_id UUID PRIMARY KEY REFERENCES matches(id) ON DELETE CASCADE,
  team1_score INTEGER NOT NULL CHECK (team1_score >= 0),
  team2_score INTEGER NOT NULL CHECK (team2_score >= 0),
  winning_team INTEGER NOT NULL CHECK (winning_team IN (1, 2)),
  duration_minutes INTEGER CHECK (duration_minutes > 0 AND duration_minutes < 180),
  score_entered_at TIMESTAMPTZ DEFAULT NOW(),
  recorded_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  -- Ensure one team has higher score
  CONSTRAINT valid_winner CHECK (
    (winning_team = 1 AND team1_score > team2_score) OR
    (winning_team = 2 AND team2_score > team1_score)
  )
);

-- Indexes for match_scores
CREATE INDEX idx_match_scores_recorded_by ON match_scores(recorded_by);
CREATE INDEX idx_match_scores_winning_team ON match_scores(winning_team);

-- =====================================================
-- PLAYER_STATISTICS TABLE (Materialized View Alternative)
-- =====================================================
CREATE TABLE player_statistics (
  player_id UUID PRIMARY KEY REFERENCES players(id) ON DELETE CASCADE,
  total_events INTEGER DEFAULT 0,
  total_matches INTEGER DEFAULT 0,
  total_wins INTEGER DEFAULT 0,
  total_losses INTEGER DEFAULT 0,
  win_percentage DECIMAL(5,2),
  total_points_for INTEGER DEFAULT 0,
  total_points_against INTEGER DEFAULT 0,
  point_differential INTEGER DEFAULT 0,
  avg_points_per_match DECIMAL(5,2),
  total_match_duration INTEGER DEFAULT 0,
  avg_match_duration DECIMAL(5,2),
  best_partner_id UUID REFERENCES players(id),
  best_partner_win_pct DECIMAL(5,2),
  most_faced_opponent_id UUID REFERENCES players(id),
  most_faced_count INTEGER,
  last_played DATE,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for player_statistics
CREATE INDEX idx_player_stats_win_pct ON player_statistics(win_percentage DESC);
CREATE INDEX idx_player_stats_last_played ON player_statistics(last_played DESC);

-- =====================================================
-- PARTNERSHIP_HISTORY TABLE
-- =====================================================
CREATE TABLE partnership_history (
  player1_id UUID NOT NULL REFERENCES players(id),
  player2_id UUID NOT NULL REFERENCES players(id),
  times_partnered INTEGER DEFAULT 0,
  wins_together INTEGER DEFAULT 0,
  losses_together INTEGER DEFAULT 0,
  win_percentage DECIMAL(5,2),
  last_partnered DATE,
  PRIMARY KEY (player1_id, player2_id),
  -- Ensure player1_id < player2_id to avoid duplicates
  CONSTRAINT ordered_players CHECK (player1_id < player2_id)
);

-- Indexes for partnership_history
CREATE INDEX idx_partnership_player1 ON partnership_history(player1_id);
CREATE INDEX idx_partnership_player2 ON partnership_history(player2_id);
CREATE INDEX idx_partnership_count ON partnership_history(times_partnered DESC);

-- =====================================================
-- OPPONENT_HISTORY TABLE
-- =====================================================
CREATE TABLE opponent_history (
  player_id UUID NOT NULL REFERENCES players(id),
  opponent_id UUID NOT NULL REFERENCES players(id),
  times_faced INTEGER DEFAULT 0,
  wins_against INTEGER DEFAULT 0,
  losses_against INTEGER DEFAULT 0,
  win_percentage DECIMAL(5,2),
  last_faced DATE,
  PRIMARY KEY (player_id, opponent_id),
  -- Prevent self-references
  CONSTRAINT different_players CHECK (player_id != opponent_id)
);

-- Indexes for opponent_history
CREATE INDEX idx_opponent_player ON opponent_history(player_id);
CREATE INDEX idx_opponent_opponent ON opponent_history(opponent_id);
CREATE INDEX idx_opponent_count ON opponent_history(times_faced DESC);

-- =====================================================
-- UPDATE TRIGGERS
-- =====================================================

-- Auto-update updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply update trigger to all tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_players_updated_at BEFORE UPDATE ON players
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_event_players_updated_at BEFORE UPDATE ON event_players
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rounds_updated_at BEFORE UPDATE ON rounds
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON matches
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_match_scores_updated_at BEFORE UPDATE ON match_scores
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_players ENABLE ROW LEVEL SECURITY;
ALTER TABLE rounds ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_players ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_statistics ENABLE ROW LEVEL SECURITY;
ALTER TABLE partnership_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE opponent_history ENABLE ROW LEVEL SECURITY;

-- Users table policies
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Events table policies
CREATE POLICY "Anyone can view events" ON events
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create events" ON events
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Event creators can update own events" ON events
  FOR UPDATE USING (auth.uid() = created_by);

CREATE POLICY "Event creators can delete own events" ON events
  FOR DELETE USING (auth.uid() = created_by);

-- Players table policies
CREATE POLICY "Anyone can view players" ON players
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create players" ON players
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update players" ON players
  FOR UPDATE USING (auth.uid() IS NOT NULL);

-- Event_players table policies
CREATE POLICY "Anyone can view event registrations" ON event_players
  FOR SELECT USING (true);

CREATE POLICY "Event creators can manage registrations" ON event_players
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM events 
      WHERE events.id = event_players.event_id 
      AND events.created_by = auth.uid()
    )
  );

-- Rounds table policies
CREATE POLICY "Anyone can view rounds" ON rounds
  FOR SELECT USING (true);

CREATE POLICY "Event creators can manage rounds" ON rounds
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM events 
      WHERE events.id = rounds.event_id 
      AND events.created_by = auth.uid()
    )
  );

-- Matches table policies
CREATE POLICY "Anyone can view matches" ON matches
  FOR SELECT USING (true);

CREATE POLICY "Event creators can manage matches" ON matches
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM events 
      WHERE events.id = matches.event_id 
      AND events.created_by = auth.uid()
    )
  );

-- Match_players table policies
CREATE POLICY "Anyone can view match players" ON match_players
  FOR SELECT USING (true);

CREATE POLICY "Event creators can manage match players" ON match_players
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM matches
      JOIN events ON events.id = matches.event_id
      WHERE matches.id = match_players.match_id 
      AND events.created_by = auth.uid()
    )
  );

-- Match_scores table policies
CREATE POLICY "Anyone can view scores" ON match_scores
  FOR SELECT USING (true);

CREATE POLICY "Event creators can manage scores" ON match_scores
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM matches
      JOIN events ON events.id = matches.event_id
      WHERE matches.id = match_scores.match_id 
      AND events.created_by = auth.uid()
    )
  );

-- Statistics table policies (read-only for all)
CREATE POLICY "Anyone can view player statistics" ON player_statistics
  FOR SELECT USING (true);

CREATE POLICY "Anyone can view partnership history" ON partnership_history
  FOR SELECT USING (true);

CREATE POLICY "Anyone can view opponent history" ON opponent_history
  FOR SELECT USING (true);

-- =====================================================
-- HELPFUL VIEWS
-- =====================================================

-- Current active events
CREATE VIEW active_events AS
SELECT * FROM events 
WHERE status = 'active' 
AND event_date >= CURRENT_DATE
ORDER BY event_date, start_time;

-- Today's events
CREATE VIEW todays_events AS
SELECT * FROM events 
WHERE event_date = CURRENT_DATE
ORDER BY start_time;

-- Match details with player names
CREATE VIEW match_details AS
SELECT 
  m.*,
  r.round_number,
  e.name as event_name,
  e.event_date,
  t1p1.name as team1_player1,
  t1p2.name as team1_player2,
  t2p1.name as team2_player1,
  t2p2.name as team2_player2,
  ms.team1_score,
  ms.team2_score,
  ms.winning_team
FROM matches m
JOIN rounds r ON r.id = m.round_id
JOIN events e ON e.id = m.event_id
LEFT JOIN match_players mp1 ON mp1.match_id = m.id AND mp1.team = 1 AND mp1.position = 1
LEFT JOIN match_players mp2 ON mp2.match_id = m.id AND mp1.team = 1 AND mp1.position = 2
LEFT JOIN match_players mp3 ON mp3.match_id = m.id AND mp1.team = 2 AND mp1.position = 1
LEFT JOIN match_players mp4 ON mp4.match_id = m.id AND mp1.team = 2 AND mp1.position = 2
LEFT JOIN players t1p1 ON t1p1.id = mp1.player_id
LEFT JOIN players t1p2 ON t1p2.id = mp2.player_id
LEFT JOIN players t2p1 ON t2p1.id = mp3.player_id
LEFT JOIN players t2p2 ON t2p2.id = mp4.player_id
LEFT JOIN match_scores ms ON ms.match_id = m.id;

-- Player standings for an event
CREATE VIEW event_standings AS
WITH player_results AS (
  SELECT 
    ep.event_id,
    ep.player_id,
    p.name as player_name,
    COUNT(DISTINCT m.id) as matches_played,
    COUNT(DISTINCT CASE 
      WHEN ms.winning_team = mp.team THEN m.id 
    END) as wins,
    COUNT(DISTINCT CASE 
      WHEN ms.winning_team != mp.team THEN m.id 
    END) as losses,
    COALESCE(SUM(CASE 
      WHEN mp.team = 1 THEN ms.team1_score 
      ELSE ms.team2_score 
    END), 0) as points_for,
    COALESCE(SUM(CASE 
      WHEN mp.team = 1 THEN ms.team2_score 
      ELSE ms.team1_score 
    END), 0) as points_against
  FROM event_players ep
  JOIN players p ON p.id = ep.player_id
  LEFT JOIN match_players mp ON mp.player_id = ep.player_id
  LEFT JOIN matches m ON m.id = mp.match_id AND m.event_id = ep.event_id
  LEFT JOIN match_scores ms ON ms.match_id = m.id
  WHERE ep.status IN ('present', 'departed')
  GROUP BY ep.event_id, ep.player_id, p.name
)
SELECT 
  *,
  points_for - points_against as point_differential,
  CASE 
    WHEN matches_played > 0 
    THEN ROUND(wins::decimal / matches_played * 100, 2) 
    ELSE 0 
  END as win_percentage
FROM player_results
ORDER BY wins DESC, point_differential DESC, points_for DESC;