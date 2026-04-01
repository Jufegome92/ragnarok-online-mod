local MAX_DRAGON_FORCE = 120
local STATUS_PREFIX = "DNM_DRAGON_FORCE_"
local trackedCharacters = {}
local appliedAmounts = {}
local lastRefresh = 0
local refreshIntervalMs = 2000

-- Subclass passives that should receive Dragon Force and their casting ability.
local SUBCLASS_DRAGON_FORCE_ABILITIES = {
    DNM_Moonlord_DragonForce = "Intelligence",
    DNM_Moonlord_Training = "Intelligence",
    DNM_Reaper_DragonForce = "Wisdom",
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

local function getDragonForceAbility(character)
    for passive, ability in pairs(SUBCLASS_DRAGON_FORCE_ABILITIES) do
        if Osi.HasPassive(character, passive) == 1 then
            return ability
        end
    end

    return nil
end

local function getDragonForceAmount(character)
    local ability = getDragonForceAbility(character)
    if ability == nil then
        return nil
    end

    local level = Osi.GetLevel(character) or 1
    local abilityScore = Osi.GetAbility(character, ability) or 10
    local modifier = math.floor((abilityScore - 10) / 2)
    local amount = modifier * level

    -- Keep level-1 spell-like gameplay functional even on low-stat test builds.
    if amount < 1 then
        amount = 1
    end

    if amount > MAX_DRAGON_FORCE then
        amount = MAX_DRAGON_FORCE
    end

    return amount
end

local function statusName(amount)
    return STATUS_PREFIX .. tostring(amount)
end

local function clearDragonForceStatus(character, amount)
    if amount ~= nil and amount > 0 then
        local status = statusName(amount)
        while Osi.HasActiveStatus(character, status) == 1 do
            Osi.RemoveStatus(character, status)
        end
    end
end

local function clearAllDragonForceStatuses(character)
    for i = 1, MAX_DRAGON_FORCE do
        clearDragonForceStatus(character, i)
    end
end

local function refreshDragonForce(character)
    if character == nil or character == "" then
        return
    end

    local amount = getDragonForceAmount(character)
    local previousAmount = appliedAmounts[character]

    if amount == nil then
        clearAllDragonForceStatuses(character)
        appliedAmounts[character] = nil
        trackedCharacters[character] = nil
        return
    end

    trackedCharacters[character] = true

    if previousAmount == nil then
        clearAllDragonForceStatuses(character)
    elseif previousAmount == amount then
        return
    else
        clearDragonForceStatus(character, previousAmount)
    end

    if amount > 0 then
        Osi.ApplyStatus(character, statusName(amount), -1.0, 1, character)
    end

    appliedAmounts[character] = amount
end

local function queueRefresh(character)
    delayedCall(1000, function()
        refreshDragonForce(character)
    end)
end

Ext.Osiris.RegisterListener("GainedControl", 1, "after", function(character)
    trackedCharacters[character] = true
    queueRefresh(character)
end)

Ext.Osiris.RegisterListener("LeveledUp", 1, "after", function(character)
    trackedCharacters[character] = true
    queueRefresh(character)
end)

Ext.Osiris.RegisterListener("RespecCompleted", 1, "after", function(character)
    trackedCharacters[character] = true
    queueRefresh(character)
end)

Ext.Events.Tick:Subscribe(function()
    local now = Ext.Utils.MonotonicTime()
    if now - lastRefresh < refreshIntervalMs then
        return
    end

    lastRefresh = now
    for character, _ in pairs(trackedCharacters) do
        refreshDragonForce(character)
    end
end)
