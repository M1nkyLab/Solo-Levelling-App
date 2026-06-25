-- ══════════════════════════════════════════════════════════════════
-- SHADOW MONARCH APP — DATABASE MIGRATION FIX
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ══════════════════════════════════════════════════════════════════

-- ── 1. Add missing columns to `players` ───────────────────────────
ALTER TABLE players
  ADD COLUMN IF NOT EXISTS strength              INTEGER DEFAULT 10 NOT NULL,
  ADD COLUMN IF NOT EXISTS agility               INTEGER DEFAULT 10 NOT NULL,
  ADD COLUMN IF NOT EXISTS vitality              INTEGER DEFAULT 10 NOT NULL,
  ADD COLUMN IF NOT EXISTS intelligence          INTEGER DEFAULT 10 NOT NULL,
  ADD COLUMN IF NOT EXISTS sense                 INTEGER DEFAULT 10 NOT NULL,
  ADD COLUMN IF NOT EXISTS available_stat_points INTEGER DEFAULT 0  NOT NULL,
  ADD COLUMN IF NOT EXISTS total_exp             INTEGER DEFAULT 0  NOT NULL;

-- ── 2. Add missing columns to `workout_schedules` ─────────────────
ALTER TABLE workout_schedules
  ADD COLUMN IF NOT EXISTS days_of_week  INTEGER[] DEFAULT ARRAY[1,3,5] NOT NULL,
  ADD COLUMN IF NOT EXISTS is_configured BOOLEAN   DEFAULT FALSE NOT NULL,
  ADD COLUMN IF NOT EXISTS updated_at    TIMESTAMPTZ DEFAULT NOW();

-- ── 3. Ensure RLS is enabled on all tables ────────────────────────
ALTER TABLE players              ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_quests         ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_schedules    ENABLE ROW LEVEL SECURITY;
ALTER TABLE quest_history        ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_notifications ENABLE ROW LEVEL SECURITY;

-- ── 4. FIX: Add missing INSERT policy for players ─────────────────
-- This is the main cause of "new row violates row-level security policy"
DROP POLICY IF EXISTS "Players can create their own profile" ON players;
CREATE POLICY "Players can create their own profile"
  ON players FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Ensure SELECT and UPDATE policies exist
DROP POLICY IF EXISTS "Players can view their own profile"   ON players;
DROP POLICY IF EXISTS "Players can update their own profile" ON players;

CREATE POLICY "Players can view their own profile"
  ON players FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Players can update their own profile"
  ON players FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ── 5. RLS for daily_quests ───────────────────────────────────────
DROP POLICY IF EXISTS "Players can view their own quests"   ON daily_quests;
DROP POLICY IF EXISTS "Players can insert their own quests" ON daily_quests;
DROP POLICY IF EXISTS "Players can update their own quests" ON daily_quests;
DROP POLICY IF EXISTS "Players can delete their own quests" ON daily_quests;

CREATE POLICY "Players can view their own quests"
  ON daily_quests FOR SELECT
  USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

CREATE POLICY "Players can insert their own quests"
  ON daily_quests FOR INSERT
  WITH CHECK (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

CREATE POLICY "Players can update their own quests"
  ON daily_quests FOR UPDATE
  USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

CREATE POLICY "Players can delete their own quests"
  ON daily_quests FOR DELETE
  USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

-- ── 6. RLS for workout_schedules ──────────────────────────────────
DROP POLICY IF EXISTS "Players can manage their own schedule" ON workout_schedules;

CREATE POLICY "Players can manage their own schedule"
  ON workout_schedules FOR ALL
  USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()))
  WITH CHECK (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

-- ── 7. RLS for quest_history ──────────────────────────────────────
DROP POLICY IF EXISTS "Players can manage their own quest history" ON quest_history;

CREATE POLICY "Players can manage their own quest history"
  ON quest_history FOR ALL
  USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()))
  WITH CHECK (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

-- ── 8. RLS for system_notifications ──────────────────────────────
DROP POLICY IF EXISTS "Players can view their own notifications" ON system_notifications;

CREATE POLICY "Players can view their own notifications"
  ON system_notifications FOR ALL
  USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()))
  WITH CHECK (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

-- ── 9. Create/replace the add_player_xp RPC ──────────────────────
-- SECURITY DEFINER = runs as DB owner, bypasses RLS safely inside function.
CREATE OR REPLACE FUNCTION public.add_player_xp(p_id UUID, xp_amount INTEGER)
RETURNS SETOF players
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    p_rec          players%ROWTYPE;
    new_xp         INTEGER;
    new_lvl        INTEGER;
    new_max_xp     INTEGER;
    stat_per_level INTEGER := 3;
BEGIN
    SELECT * INTO p_rec FROM players WHERE id = p_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Player not found: %', p_id;
    END IF;

    new_xp     := p_rec.current_exp + xp_amount;
    new_lvl    := p_rec.level;
    new_max_xp := p_rec.max_exp;
    p_rec.total_exp := p_rec.total_exp + xp_amount;

    -- Level-up loop (matches SystemLogic.dart formula)
    WHILE new_xp >= new_max_xp AND new_lvl < 100 LOOP
        new_xp  := new_xp - new_max_xp;
        new_lvl := new_lvl + 1;

        -- XP threshold: 100 * (level^2 * 0.4 + level * 0.6)
        new_max_xp := ROUND(100.0 * (new_lvl * new_lvl * 0.4 + new_lvl * 0.6));

        -- Add stat points
        IF new_lvl IN (10, 25, 45, 70, 90) THEN
            p_rec.available_stat_points := p_rec.available_stat_points + 6;
        ELSE
            p_rec.available_stat_points := p_rec.available_stat_points + 3;
        END IF;

        -- Rank from level
        p_rec.rank := CASE
            WHEN new_lvl >= 91 THEN 'S'
            WHEN new_lvl >= 71 THEN 'A'
            WHEN new_lvl >= 46 THEN 'B'
            WHEN new_lvl >= 26 THEN 'C'
            WHEN new_lvl >= 11 THEN 'D'
            ELSE                    'E'
        END;

        -- Full HP heal on level-up
        p_rec.current_hp := p_rec.max_hp;
    END LOOP;

    RETURN QUERY
    UPDATE players
    SET current_exp           = new_xp,
        level                 = new_lvl,
        max_exp               = new_max_xp,
        total_exp             = p_rec.total_exp,
        rank                  = p_rec.rank,
        current_hp            = p_rec.current_hp,
        available_stat_points = p_rec.available_stat_points
    WHERE id = p_id
    RETURNING *;
END;
$$;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION public.add_player_xp(UUID, INTEGER) TO authenticated;

-- ── 10. Fix days_of_week for any empty existing schedules ─────────
UPDATE workout_schedules
SET days_of_week = ARRAY[1, 3, 5]
WHERE days_of_week IS NULL OR array_length(days_of_week, 1) IS NULL;

-- ── 11. Verify ────────────────────────────────────────────────────
SELECT
  'players columns' AS "table",
  array_agg(column_name ORDER BY ordinal_position) AS columns
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'players'
UNION ALL
SELECT
  'workout_schedules columns',
  array_agg(column_name ORDER BY ordinal_position)
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'workout_schedules';
