-- scoring.lua
-- Thresholded scoring and penalties for Solo mode.
-- Awards double each threshold; penalties scale 2x at T1 then ×2.25 per threshold.

local M = {}

local BASE_AWARD_T1 = {
  ["High Card"]      = 1,
  ["Pair"]           = 2,
  ["Two Pair"]       = 4,
  ["Three of a Kind"]= 6,
  ["Flush"]          = 8,
  ["Straight"]       = 8,
  ["Full House"]     = 8,
  ["Four of a Kind"] = 16,
}

local function clamp_threshold(t) return math.max(1, math.floor(t or 1)) end

function M.init(S)
  S.meta = S.meta or {}
  if S.meta.threshold == nil then S.meta.threshold = 1 end
  if S.meta.score == nil then S.meta.score = 0 end
  if S.meta.punish_level == nil then S.meta.punish_level = 0 end -- +1 every 30 moves (hook later)
end

function M.get_award(threshold, hand_name)
  local base = BASE_AWARD_T1[hand_name] or 0
  local mult = 2 ^ (clamp_threshold(threshold) - 1) -- x1 at T1, x2 at T2, x4 at T3
  return base * mult
end

-- Penalty progression per Rule Book:
-- T1 Penalty = 2 × (T1 award)
-- T2 Penalty = ceil(T1 Penalty × 2.25)
-- T3 Penalty = ceil(T2 Penalty × 2.25)

-- Punishments per updated spec:
-- T1: punishment = award (×1)
-- T2: punishment = ceil(1.5 × award at same threshold)
-- T3: punishment = 2 × award at same threshold
-- T4+: start from T3 punishment, then compound ×2.25 per threshold (ceil each step)
local function penalty_for_threshold(t, hand_name)
  t = clamp_threshold(t)
  if t <= 3 then
    local aw = M.get_award(t, hand_name)
    local mult = (t == 1 and 1.0) or (t == 2 and 1.5) or 2.0
    return math.ceil(aw * mult)
  else
    local p3 = math.ceil(M.get_award(3, hand_name) * 2.0)
    local cur = p3
    for k = 4, t do
      cur = math.ceil(cur * 2.25)
    end
    return cur
  end
end

function M.apply_award(S, hand_name)
  local t = clamp_threshold(S.meta.threshold)
  local pts = M.get_award(t, hand_name)
  S.meta.score = (S.meta.score or 0) + pts
  return pts
end

function M.apply_penalty(S, hand_name)
  local t = clamp_threshold(S.meta.threshold)
  local pts = penalty_for_threshold(t, hand_name)
  S.meta.score = (S.meta.score or 0) - pts
  return pts
end

return M
