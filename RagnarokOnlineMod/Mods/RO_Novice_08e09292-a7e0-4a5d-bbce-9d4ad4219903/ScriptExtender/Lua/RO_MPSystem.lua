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
local REFRESH_INTERVAL_MS = 2000

local trackedCharacters = {}
local appliedDeltas = {}
local lastRefresh = 0

local function DelayedCall(delayInMs, func)
    local startTime = Ext.Utils.MonotonicTime()
    local handlerId
    handlerId = Ext.Events.Tick:Subscribe(function()
        if Ext.Utils.MonotonicTime() - startTime > delayInMs then
            Ext.Events.Tick:Unsubscribe(handlerId)
            func()
        end
    end)
end

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
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
    -- No marker passive = Novice fixed path, no dynamic formula.
    return nil
end

local function getDesiredMP(character)
    local ability = getFormulaAbility(character)
    if ability == nil then
        return nil
    end

    local okLv, level = pcall(Osi.GetLevel, character)
    if not okLv or type(level) ~= "number" then level = 1 end

    local okSc, score = pcall(Osi.GetAbility, character, ability)
    if not okSc or type(score) ~= "number" then score = 10 end

    local spellMod = math.floor((score - 10) / 2)

    -- (4 + (2 * character_level)) + (character_level * floor(spellcasting_modifier / 2))
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
        if d ~= 0 then
            local id = adjustPassiveIdFromDelta(d)
            if hasPassive(character, id) then
                pcall(Osi.RemovePassive, character, id)
            end
        end
    end
end

local function applyDelta(character, delta)
    local previous = appliedDeltas[character]

    if previous ~= nil and previous == delta then
        return
    end

    if previous ~= nil then
        local prevId = adjustPassiveIdFromDelta(previous)
        if hasPassive(character, prevId) then
            pcall(Osi.RemovePassive, character, prevId)
        end
    else
        clearAdjustPassives(character)
    end

    if delta ~= 0 then
        pcall(Osi.AddPassive, character, adjustPassiveIdFromDelta(delta))
    end

    appliedDeltas[character] = delta
end

local function refreshCharacter(character)
    if character == nil or character == "" then
        return
    end

    local desired = getDesiredMP(character)
    if desired == nil then
        if appliedDeltas[character] ~= nil then
            clearAdjustPassives(character)
            appliedDeltas[character] = nil
        end
        trackedCharacters[character] = nil
        return
    end

    trackedCharacters[character] = true

    local delta = clamp(desired - NOVICE_BASE_MP, ADJUST_MIN, ADJUST_MAX)
    applyDelta(character, delta)
end

local function isPlayerOrFollower(character)
    local okP, isPlayer = pcall(Osi.IsPlayer, character)
    if okP and isPlayer == 1 then return true end
    local okF, isFollower = pcall(Osi.IsPartyFollower, character)
    if okF and isFollower == 1 then return true end
    return false
end

local function queueRefresh(character)
    if not character or character == "" then return end
    if not isPlayerOrFollower(character) then return end

    trackedCharacters[character] = true
    DelayedCall(1000, function()
        refreshCharacter(character)
    end)
end

local function trackCurrentParty()
    local ok, party = pcall(function() return Osi.DB_Players:Get(nil) end)
    if not ok or not party then return end
    for _, p in pairs(party) do
        local character = p[1]
        trackedCharacters[character] = true
        DelayedCall(1200, function()
            refreshCharacter(character)
        end)
    end
end

Ext.Osiris.RegisterListener("GainedControl", 1, "after", function(character)
    queueRefresh(character)
end)

Ext.Osiris.RegisterListener("LeveledUp", 1, "after", function(character)
    queueRefresh(character)
end)

Ext.Osiris.RegisterListener("RespecCompleted", 1, "after", function(character)
    queueRefresh(character)
end)

Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(character)
    queueRefresh(character)
end)

Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(level, _)
    if level ~= "SYS_CC_I" then
        trackCurrentParty()
    end
end)

Ext.Events.Tick:Subscribe(function()
    local now = Ext.Utils.MonotonicTime()
    if now - lastRefresh < REFRESH_INTERVAL_MS then
        return
    end

    lastRefresh = now
    for character, _ in pairs(trackedCharacters) do
        local ok = pcall(function()
            if isPlayerOrFollower(character) then
                refreshCharacter(character)
            else
                trackedCharacters[character] = nil
                appliedDeltas[character] = nil
            end
        end)
        if not ok then
            trackedCharacters[character] = nil
            appliedDeltas[character] = nil
        end
    end
end)
