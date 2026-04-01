local STATUS_PREFIX = "DNM_BATTLE_EXERTION_"
local REFILL_STATUS = "DNM_BATTLE_EXERTION_REFILL"
local MAX_BATTLE_EXERTION = 20
local trackedCharacters = {}
local appliedAmounts = {}
local pendingCombatRefill = {}
local lastRefresh = 0
local refreshIntervalMs = 2000

local SUBCLASS_BATTLE_EXERTION_PASSIVES = {
    DNM_Moonlord_BattleExertion = true,
    DNM_Moonlord_Training = true,
    DNM_Reaper_BattleExertion = true,
    DNM_Reaper_Training = true
}

-- Extend this table as new subclasses are added.
local SUBCLASS_SPELLCASTING_ABILITIES = {
    DNM_Moonlord_Training = "Intelligence",
    DNM_Reaper_Training = "Wisdom"
}

local function delayedCall(delayInMs, func)
    local startTime = Ext.Utils.MonotonicTime()
    local handlerId
    handlerId = Ext.Events.Tick:Subscribe(function()
        if Ext.Utils.MonotonicTime() - startTime > delayInMs then
            Ext.Events.Tick:Unsubscribe(handlerId)
            func()
        end
    end)
end

local function getProficiencyBonus(level)
    if level >= 9 then
        return 4
    elseif level >= 5 then
        return 3
    else
        return 2
    end
end

local function getSubclassSpellcastingModifier(character)
    for passive, ability in pairs(SUBCLASS_SPELLCASTING_ABILITIES) do
        if Osi.HasPassive(character, passive) == 1 then
            local score = Osi.GetAbility(character, ability) or 10
            return math.floor((score - 10) / 2)
        end
    end

    return nil
end

local function hasBattleExertionAccess(character)
    for passive, _ in pairs(SUBCLASS_BATTLE_EXERTION_PASSIVES) do
        if Osi.HasPassive(character, passive) == 1 then
            return true
        end
    end

    return false
end

local function getBattleExertionAmount(character)
    if not hasBattleExertionAccess(character) then
        return nil
    end

    local level = Osi.GetLevel(character) or 1
    local proficiency = getProficiencyBonus(level)
    local spellcastingModifier = getSubclassSpellcastingModifier(character)

    if spellcastingModifier == nil then
        return nil
    end

    local amount = proficiency + spellcastingModifier
    if amount < 1 then
        amount = 1
    end

    if amount > MAX_BATTLE_EXERTION then
        amount = MAX_BATTLE_EXERTION
    end

    return amount
end

local function statusName(amount)
    return STATUS_PREFIX .. tostring(amount)
end

local function clearStatus(character, amount)
    if amount ~= nil and amount > 0 then
        local status = statusName(amount)
        while Osi.HasActiveStatus(character, status) == 1 do
            Osi.RemoveStatus(character, status)
        end
    end
end

local function clearAllStatuses(character)
    for i = 1, MAX_BATTLE_EXERTION do
        clearStatus(character, i)
    end
end

local function triggerRefill(character)
    while Osi.HasActiveStatus(character, REFILL_STATUS) == 1 do
        Osi.RemoveStatus(character, REFILL_STATUS)
    end
    Osi.ApplyStatus(character, REFILL_STATUS, 1.0, 1, character)
end

local function refreshBattleExertion(character, forceRefill)
    if character == nil or character == "" then
        return
    end

    local amount = getBattleExertionAmount(character)
    local previousAmount = appliedAmounts[character]

    if amount == nil then
        clearAllStatuses(character)
        appliedAmounts[character] = nil
        trackedCharacters[character] = nil
        pendingCombatRefill[character] = nil
        return
    end

    trackedCharacters[character] = true

    local currentStatus = statusName(amount)
    local hasCurrentStatus = Osi.HasActiveStatus(character, currentStatus) == 1
    if not forceRefill and previousAmount == amount and hasCurrentStatus then
        return
    end

    clearAllStatuses(character)
    Osi.ApplyStatus(character, currentStatus, -1.0, 1, character)
    appliedAmounts[character] = amount

    if forceRefill then
        triggerRefill(character)
    end
end

local function queueRefresh(character, forceRefill)
    delayedCall(300, function()
        refreshBattleExertion(character, forceRefill == true)
    end)
end

Ext.Osiris.RegisterListener("GainedControl", 1, "after", function(character)
    trackedCharacters[character] = true
    queueRefresh(character, false)
end)

Ext.Osiris.RegisterListener("LeveledUp", 1, "after", function(character)
    trackedCharacters[character] = true
    queueRefresh(character, true)
end)

Ext.Osiris.RegisterListener("RespecCompleted", 1, "after", function(character)
    trackedCharacters[character] = true
    queueRefresh(character, true)
end)

Ext.Osiris.RegisterListener("EnteredCombat", 2, "after", function(character, _combatGuid)
    trackedCharacters[character] = true
    queueRefresh(character, true)
    delayedCall(1200, function()
        refreshBattleExertion(character, true)
    end)
    pendingCombatRefill[character] = {
        attempts = 5,
        nextAt = Ext.Utils.MonotonicTime() + 1800
    }
end)

Ext.Osiris.RegisterListener("LeftCombat", 2, "after", function(character, _combatGuid)
    trackedCharacters[character] = true
    queueRefresh(character, false)
    pendingCombatRefill[character] = nil
end)

Ext.Events.Tick:Subscribe(function()
    local now = Ext.Utils.MonotonicTime()
    if now - lastRefresh < refreshIntervalMs then
        return
    end

    lastRefresh = now
    for character, _ in pairs(trackedCharacters) do
        refreshBattleExertion(character, false)
    end

    local nowMs = Ext.Utils.MonotonicTime()
    for character, state in pairs(pendingCombatRefill) do
        if state.attempts <= 0 then
            pendingCombatRefill[character] = nil
        elseif nowMs >= state.nextAt then
            refreshBattleExertion(character, true)
            state.attempts = state.attempts - 1
            state.nextAt = nowMs + 700
            if state.attempts <= 0 then
                pendingCombatRefill[character] = nil
            end
        end
    end
end)
