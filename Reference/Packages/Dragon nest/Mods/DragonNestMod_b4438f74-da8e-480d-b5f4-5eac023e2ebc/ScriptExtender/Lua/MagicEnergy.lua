local MAGIC_ENERGY_PASSIVE = "DNM_Moonlord_MagicEnergy"
local STATUS_PREFIX = "DNM_MAGIC_ENERGY_"
local trackedCharacters = {}
local appliedAmounts = {}
local lastRefresh = 0
local refreshIntervalMs = 2000

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

local function getMagicEnergyAmount(character)
    if Osi.HasPassive(character, MAGIC_ENERGY_PASSIVE) ~= 1 then
        return nil
    end

    local level = Osi.GetLevel(character) or 1
    if level >= 9 then
        return 10
    elseif level >= 5 then
        return 8
    else
        return 6
    end
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
    clearStatus(character, 6)
    clearStatus(character, 8)
    clearStatus(character, 10)
end

local function refreshMagicEnergy(character, forceRefill)
    if character == nil or character == "" then
        return
    end

    local amount = getMagicEnergyAmount(character)
    local previousAmount = appliedAmounts[character]

    if amount == nil then
        clearAllStatuses(character)
        appliedAmounts[character] = nil
        trackedCharacters[character] = nil
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
end

local function queueRefresh(character, forceRefill)
    delayedCall(300, function()
        refreshMagicEnergy(character, forceRefill == true)
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
        refreshMagicEnergy(character, true)
    end)
end)

Ext.Osiris.RegisterListener("LeftCombat", 2, "after", function(character, _combatGuid)
    trackedCharacters[character] = true
    queueRefresh(character, false)
end)

Ext.Events.Tick:Subscribe(function()
    local now = Ext.Utils.MonotonicTime()
    if now - lastRefresh < refreshIntervalMs then
        return
    end

    lastRefresh = now
    for character, _ in pairs(trackedCharacters) do
        refreshMagicEnergy(character, false)
    end
end)