local VULTURE_STATUSES = {
    RO_ARCHER_VULTURES_EYE = true,
    RO_ARCHER_VULTURES_EYE_L5 = true,
    RO_ARCHER_VULTURES_EYE_L9 = true,
    RO_ARCHER_VULTURES_EYE_L12 = true
}

local RANGE_PASSIVE_09 = "RO_Archer_VulturesEye_LongRangeNoDisadv_09"
local RANGE_PASSIVE_15 = "RO_Archer_VulturesEye_LongRangeNoDisadv_15"
local RANGE_PASSIVE_18 = "RO_Archer_VulturesEye_LongRangeNoDisadv_18"

local ALL_RANGE_PASSIVES = {
    RANGE_PASSIVE_09,
    RANGE_PASSIVE_15,
    RANGE_PASSIVE_18
}

local REFRESH_INTERVAL_MS = 1200
local tracked = {}
local applied = {}
local lastRefresh = 0

local function pcallOsiris(fn, ...)
    local ok, a, b, c = pcall(fn, ...)
    if ok then return a, b, c end
    return nil, nil, nil
end

local function hasPassive(character, passiveId)
    local result = pcallOsiris(Osi.HasPassive, character, passiveId)
    return result == 1
end

local function hasVultureStatus(character)
    for status, _ in pairs(VULTURE_STATUSES) do
        local active = pcallOsiris(Osi.HasActiveStatus, character, status)
        if active == 1 then
            return true
        end
    end
    return false
end

local function isPlayerOrFollower(character)
    local isPlayer = pcallOsiris(Osi.IsPlayer, character)
    if isPlayer == 1 then return true end
    local isFollower = pcallOsiris(Osi.IsPartyFollower, character)
    return isFollower == 1
end

local function removeAllRangePassives(character)
    for _, passive in ipairs(ALL_RANGE_PASSIVES) do
        if hasPassive(character, passive) then
            pcall(Osi.RemovePassive, character, passive)
        end
    end
    applied[character] = nil
end

local function getRangedWeaponTemplateName(character)
    local slots = {
        "Ranged Main Weapon",
        "Ranged Offhand Weapon",
        "Ranged OffHand Weapon"
    }

    for _, slot in ipairs(slots) do
        local item = pcallOsiris(Osi.GetEquippedItem, character, slot)
        if item and item ~= "" and item ~= "NULL_00000000-0000-0000-0000-000000000000" then
            local templateUuid = pcallOsiris(Osi.GetTemplate, item)
            if templateUuid and templateUuid ~= "" then
                local template = Ext.Template.GetTemplate(templateUuid)
                if template and template.Name then
                    return string.lower(template.Name)
                end
            end
        end
    end

    return ""
end

local function passiveForCharacter(character)
    local weaponName = getRangedWeaponTemplateName(character)

    if weaponName ~= "" then
        if string.find(weaponName, "handcrossbow", 1, true) then
            return RANGE_PASSIVE_09
        end

        if string.find(weaponName, "shortbow", 1, true) then
            return RANGE_PASSIVE_15
        end
    end

    return RANGE_PASSIVE_18
end

local function refreshCharacter(character)
    if not character or character == "" then return end

    if not isPlayerOrFollower(character) then
        tracked[character] = nil
        applied[character] = nil
        return
    end

    if not hasVultureStatus(character) then
        removeAllRangePassives(character)
        tracked[character] = nil
        return
    end

    tracked[character] = true

    local desired = passiveForCharacter(character)
    if applied[character] == desired and hasPassive(character, desired) then
        return
    end

    removeAllRangePassives(character)
    pcall(Osi.AddPassive, character, desired)
    applied[character] = desired
end

local function queueRefresh(character)
    if not character or character == "" then return end
    tracked[character] = true
end

Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(character, status, _, _)
    if VULTURE_STATUSES[status] then
        queueRefresh(character)
    end
end)

Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", function(character, status, _, _)
    if VULTURE_STATUSES[status] then
        queueRefresh(character)
    end
end)

Ext.Osiris.RegisterListener("TemplateAddedTo", 4, "after", function(_, _, character, _)
    if character and character ~= "" then
        queueRefresh(character)
    end
end)

Ext.Osiris.RegisterListener("GainedControl", 1, "after", function(character)
    queueRefresh(character)
end)

Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(character)
    queueRefresh(character)
end)

Ext.Osiris.RegisterListener("LeveledUp", 1, "after", function(character)
    queueRefresh(character)
end)

Ext.Osiris.RegisterListener("RespecCompleted", 1, "after", function(character)
    queueRefresh(character)
end)

Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(level, _)
    if level ~= "SYS_CC_I" then
        local ok, party = pcall(function() return Osi.DB_Players:Get(nil) end)
        if ok and party then
            for _, row in pairs(party) do
                queueRefresh(row[1])
            end
        end
    end
end)

Ext.Events.Tick:Subscribe(function()
    local now = Ext.Utils.MonotonicTime()
    if now - lastRefresh < REFRESH_INTERVAL_MS then
        return
    end

    lastRefresh = now
    for character, _ in pairs(tracked) do
        local ok = pcall(function()
            refreshCharacter(character)
        end)

        if not ok then
            tracked[character] = nil
            applied[character] = nil
        end
    end
end)
