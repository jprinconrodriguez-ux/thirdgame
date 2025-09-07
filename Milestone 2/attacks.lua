-- attacks.lua
-- Announces a random target hand each turn and resolves penalty if missed.

local M = {}

-- T1 probabilities (Rule Book)
local T1 = {
  ["High Card"] = 21,
  ["Pair"] = 18,
  ["Two Pair"] = 16,
  ["Three of a Kind"] = 14,
  ["Flush"] = 12,
  ["Straight"] = 8,
  ["Full House"] = 7,
  ["Four of a Kind"] = 4,
}

local function pick_weighted(tbl, rng)
  local total = 0
  for _,w in pairs(tbl) do total = total + w end
  local r = (rng and rng.random or math.random)() * total
  local acc = 0
  for k,w in pairs(tbl) do
    acc = acc + w
    if r <= acc then return k end
  end
  -- fallback
  for k,_ in pairs(tbl) do return k end
end

function M.announce(S, rng, probs)
  S.combat = S.combat or {}
  local pool = probs or T1
  local target = pick_weighted(pool, rng or math)
  S.combat.current_attack = target
  S.combat.cancel_current_attack = false
  S.combat.just_played = nil
  return target
end

function M.note_played_this_turn(S, hand_name)
  S.combat = S.combat or {}
  S.combat.just_played = hand_name
end

function M.resolve(S, scoring)
  S.combat = S.combat or {}
  local target = S.combat.current_attack
  if not target then return {resolved=false} end
  if S.combat.cancel_current_attack then
    -- cleared by Skull or similar
    local res = { resolved=true, canceled=true, target=target }
    -- reset flags for next turn
    S.combat.current_attack = nil
    S.combat.cancel_current_attack = false
    S.combat.just_played = nil
    return res
  end
  if S.combat.just_played == target then
    local res = { resolved=true, protected=true, target=target }
    S.combat.current_attack = nil
    S.combat.just_played = nil
    return res
  end
  -- penalty
  local pts = 0
  if scoring and scoring.apply_penalty then
    pts = scoring.apply_penalty(S, target)
  end
  local res = { resolved=true, penalized=true, target=target, penalty=pts }
  S.combat.current_attack = nil
  S.combat.just_played = nil
  return res
end

return M
