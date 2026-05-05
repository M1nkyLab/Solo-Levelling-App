-- Optimized Supabase Schema for Shadow Monarch App

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enum for Hunter Rank
CREATE TYPE hunter_rank AS ENUM ('E', 'D', 'C', 'B', 'A', 'S');

-- Enum for Trial Status
CREATE TYPE trial_status AS ENUM ('idle', 'active', 'failed', 'penalty');

-- Players table: Enhanced with RPG stats and constraints
CREATE TABLE players (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Leveling & Rank
    level INTEGER DEFAULT 1 NOT NULL CHECK (level >= 1),
    rank hunter_rank DEFAULT 'E' NOT NULL,
    current_exp INTEGER DEFAULT 0 NOT NULL CHECK (current_exp >= 0),
    max_exp INTEGER DEFAULT 100 NOT NULL,
    
    -- Vitality System
    current_hp INTEGER DEFAULT 100 NOT NULL,
    max_hp INTEGER DEFAULT 100 NOT NULL,
    CHECK (current_hp >= 0 AND current_hp <= max_hp),
    
    -- RPG Stats (The "Shadow Monarch" System)
    strength INTEGER DEFAULT 10 NOT NULL CHECK (strength >= 1),
    agility INTEGER DEFAULT 10 NOT NULL CHECK (agility >= 1),
    vitality INTEGER DEFAULT 10 NOT NULL CHECK (vitality >= 1),
    intelligence INTEGER DEFAULT 10 NOT NULL CHECK (intelligence >= 1),
    sense INTEGER DEFAULT 10 NOT NULL CHECK (sense >= 1),
    available_stat_points INTEGER DEFAULT 0 NOT NULL CHECK (available_stat_points >= 0),
    
    -- State Tracking
    trial_status trial_status DEFAULT 'idle' NOT NULL,
    last_workout_date DATE,
    last_penalty_check TIMESTAMP WITH TIME ZONE,
    is_dead BOOLEAN DEFAULT FALSE NOT NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indices for performance
CREATE INDEX idx_players_user_id ON players(user_id);

-- Daily Quests table
CREATE TABLE daily_quests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    quest_id TEXT NOT NULL, -- 'pushups', 'situps', 'squats', 'run'
    title TEXT NOT NULL,
    current_reps INTEGER DEFAULT 0 NOT NULL CHECK (current_reps >= 0),
    is_completed BOOLEAN DEFAULT FALSE NOT NULL,
    date DATE DEFAULT CURRENT_DATE NOT NULL,
    UNIQUE(player_id, quest_id, date)
);

-- Index for historical queries and daily reset checks
CREATE INDEX idx_daily_quests_date ON daily_quests(date);
CREATE INDEX idx_daily_quests_player_id ON daily_quests(player_id);

-- ── FUNCTIONS & TRIGGERS ──────────────────────────────────────────────────

-- Trigger to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_players_updated_at
    BEFORE UPDATE ON players
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to handle Level-up logic server-side
-- This prevents race conditions and ensures math consistency
CREATE OR REPLACE FUNCTION add_player_xp(p_id UUID, xp_amount INTEGER)
RETURNS SETOF players AS $$
DECLARE
    p_rec players%ROWTYPE;
    new_xp INTEGER;
    new_lvl INTEGER;
    new_max_xp INTEGER;
    stat_points_per_level INTEGER := 3;
BEGIN
    SELECT * INTO p_rec FROM players WHERE id = p_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Player not found';
    END IF;

    new_xp := p_rec.current_exp + xp_amount;
    new_lvl := p_rec.level;
    new_max_xp := p_rec.max_exp;

    -- Level up loop
    WHILE new_xp >= new_max_xp LOOP
        new_xp := new_xp - new_max_xp;
        new_lvl := new_lvl + 1;
        
        -- Formula from SystemLogic: (100 * (level^2 * 0.4 + level * 0.6))
        new_max_xp := ROUND(100 * (new_lvl * new_lvl * 0.4 + new_lvl * 0.6));
        
        -- Add stat points
        p_rec.available_stat_points := p_rec.available_stat_points + stat_points_per_level;
        
        -- Determine Rank (Simplified mapping for DB)
        IF new_lvl >= 91 THEN p_rec.rank := 'S';
        ELSIF new_lvl >= 71 THEN p_rec.rank := 'A';
        ELSIF new_lvl >= 46 THEN p_rec.rank := 'B';
        ELSIF new_lvl >= 26 THEN p_rec.rank := 'C';
        ELSIF new_lvl >= 11 THEN p_rec.rank := 'D';
        ELSE p_rec.rank := 'E';
        END IF;

        -- Heal on level up
        p_rec.current_hp := p_rec.max_hp;
    END LOOP;

    UPDATE players 
    SET current_exp = new_xp,
        level = new_lvl,
        max_exp = new_max_xp,
        rank = p_rec.rank,
        current_hp = p_rec.current_hp,
        available_stat_points = p_rec.available_stat_points
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql;

-- ── RLS POLICIES ──────────────────────────────────────────────────────────
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_quests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Players can view their own profile"
    ON players FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Players can update their own profile"
    ON players FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Players can view their own quests"
    ON daily_quests FOR SELECT
    USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

CREATE POLICY "Players can update their own quests"
    ON daily_quests FOR UPDATE
    USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

-- RLS for Quest History
ALTER TABLE quest_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Players can view their own history"
    ON quest_history FOR SELECT
    USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

-- RLS for Notifications
ALTER TABLE system_notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Players can view their own notifications"
    ON system_notifications FOR SELECT
    USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

CREATE POLICY "Players can update their own notifications"
    ON system_notifications FOR UPDATE
    USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));
   ELSIF new_lvl >= 11 THEN p_rec.rank := 'D';
        ELSE p_rec.rank := 'E';
        END IF;

        -- Heal on level up
        p_rec.current_hp := p_rec.max_hp;
    END LOOP;

    UPDATE players 
    SET current_exp = new_xp,
        level = new_lvl,
        max_exp = new_max_xp,
        rank = p_rec.rank,
        current_hp = p_rec.current_hp,
        available_stat_points = p_rec.available_stat_points
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql;

-- ── RLS POLICIES ──────────────────────────────────────────────────────────
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_quests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Players can view their own profile"
    ON players FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Players can update their own profile"
    ON players FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Players can view their own quests"
    ON daily_quests FOR SELECT
    USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

CREATE POLICY "Players can update their own quests"
    ON daily_quests FOR UPDATE
    USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));
