local MP_RESOURCE = "RO_MP"
local NOVICE_BASE_MP = 6

local FORMULA_MARKER_TO_ABILITY = {
    RO_MP_Formula_WIS = "Wisdom",
    RO_MP_Formula_INT = "Intelligence",
    RO_MP_Formula_DEX = "Dexterity",
    RO_MP_Formula_CHA = "Charisma",
    RO_MP_Formula_STR = "Strength",
    RO_MP_Formula_CON = "Constitution"
}

local ADJUST_MIN = -20
local ADJUST_MAX = 120

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function safeGetLevel(character)
    local ok, level = pcall(Osi.GetLevel, character)
    if not ok or type(level) ~= "number" then return 1 end
    return level
end

local function safeGetAbilityScore(character, abilityName)
    local ok, score = pcall(Osi.GetAbility, character, abilityName)
    if not ok or type(score) ~= "number" then return 10 end
    return score
end

local function hasPassive(character, passiveId)
    local ok, result = pcall(Osi.HasPassive, character, passiveId)
    if not ok then return false end
    return result == 1
end

local function getFormulaAbility(character)
    for marker, ability in pairs(FORMULA_MARKER_TO_ABILITY) do
        if hasPassive(character, marker) then
            return ability
        end
    end
    return nil
end

local function getDesiredMP(character)
    local ability = getFormulaAbility(character)
    if not ability then
        -- No formula marker = Novice fixed MP flow.
        return nil
    end

    local level = safeGetLevel(character)
    local score = safeGetAbilityScore(character, ability)
    local spellMod = math.floor((score - 10) / 2)

    -- (4 + (2 * level)) + (level * floor(spellcasting_modifier / 2))
    local total = (4 + (2 * level)) + (level * math.floor(spellMod / 2))
    if total < 0 then total = 0 end

    return total
end

local function adjustPassiveIdFromDelta(delta)
    local n = math.abs(delta)
    local sign = (delta >= 0) and "Plus" or "Minus"
    return string.format("RO_MP_Adjust_%s_%03d", sign, n)
end

local function clearAdjustPassives(character)
    for d = ADJUST_MIN, ADJUST_MAX do
        local id = adjustPassiveIdFromDelta(d)
        if hasPassive(character, id) then
            pcall(Osi.RemovePassive, character, id)
        end
    end
end

local function applyAdjustPassive(character, delta)
    clearAdjustPassives(character)
    if delta == 0 then return end

    local id = adjustPassiveIdFromDelta(delta)
    pcall(Osi.AddPassive, character, id)
end

local function syncCharacterMP(character)
    if not character then return end

    local desired = getDesiredMP(character)
    if desired == nil then
        -- Novice/fixed branch: ensure no dynamic adjust remains.
        clearAdjustPassives(character)
        return
    end

    local delta = clamp(desired - NOVICE_BASE_MP, ADJUST_MIN, ADJUST_MAX)
    applyAdjustPassive(character, delta)
end

local function syncIfPlayerOrFollower(character)
    if not character then return end
    local isPlayer = Osi.IsPlayer(character)
    local isFollower = Osi.IsPartyFollower(character)
    if isPlayer == 1 or isFollower == 1 then
        syncCharacterMP(character)
    end
end

Ext.Osiris.RegisterListener("GainedControl", 1, "after", function(character)
    syncIfPlayerOrFollower(character)
end)

Ext.Osiris.RegisterListener("LeveledUp", 1, "after", function(character)
    syncIfPlayerOrFollower(character)
end)

Ext.Osiris.RegisterListener("RespecCompleted", 1, "after", function(character)
    syncIfPlayerOrFollower(character)
end)
