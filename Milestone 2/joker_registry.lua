-- joker_registry.lua
-- Data model: { id, name, rarity, jtype = "passive"|"active"|"triggered", effect = "effect_key" }
-- Rarity: "common","uncommon","rare","epic","legendary","mythic"

local R = {}

-- Minimal seed set to validate the core loop. Expand in 3.3.
R.all = {
  { id="bicycle",   name="Bicycle", rarity="common",    jtype="active",   effect="draw3" },
  { id="skull",     name="Skull",   rarity="uncommon",  jtype="active",   effect="cancel_attack" },
  -- Add more as you wire up 3.3: Flush, Acrobat, Architect, Eye, etc...
  -- { id="food",   name="Food",   rarity="legendary", jtype="passive", effect="hand_cap_plus1" },
}

-- How many copies of each rarity enter the pool (placeholder until 3.3 math is finalized).
-- You can swap these counts with your rulebook numbers without touching core code.
R.rarity_counts = {
  common    = 20,
  uncommon  = 12,
  rare      =  8,
  epic      =  4,
  legendary =  2,
  mythic    =  1,
}

-- Utility: list of IDs by rarity
function R.ids_by_rarity()
  local buckets = {common={},uncommon={},rare={},epic={},legendary={},mythic={}}
  for _,j in ipairs(R.all) do
    table.insert(buckets[j.rarity], j.id)
  end
  return buckets
end

-- Lookup by id
R.by_id = {}
for _,j in ipairs(R.all) do
  R.by_id[j.id] = j
end

return R
