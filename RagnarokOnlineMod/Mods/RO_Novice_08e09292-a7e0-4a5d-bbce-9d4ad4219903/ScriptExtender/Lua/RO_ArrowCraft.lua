local TRACKED_ATTACK_SPELLS = {
    Projectile_MainHandAttack = true,
    Projectile_OffhandAttack = true,
    Projectile_RO_DoubleStrafe = true,
    Projectile_RO_DoubleStrafe_5 = true,
    Projectile_RO_DoubleStrafe_9 = true,
    Projectile_RO_DoubleStrafe_12 = true,
    Projectile_RO_DoubleStrafe_Followup = true,
    Projectile_RO_DoubleStrafe_Followup_5 = true,
    Projectile_RO_DoubleStrafe_Followup_9 = true,
    Projectile_RO_DoubleStrafe_Followup_12 = true
}

local ARROWCRAFT_STATUS_TO_PROC_STATUS = {
    RO_ARCHER_ARROW_CRAFT_Fire_L12 = "RO_ARCHER_ARROWCRAFT_PROC_FIRE_L12",
    RO_ARCHER_ARROW_CRAFT_Fire_L9 = "RO_ARCHER_ARROWCRAFT_PROC_FIRE_L9",
    RO_ARCHER_ARROW_CRAFT_Fire_L5 = "RO_ARCHER_ARROWCRAFT_PROC_FIRE_L5",
    RO_ARCHER_ARROW_CRAFT_Fire_L3 = "RO_ARCHER_ARROWCRAFT_PROC_FIRE_L3",

    RO_ARCHER_ARROW_CRAFT_Poison_L12 = "RO_ARCHER_ARROWCRAFT_PROC_POISON_L12",
    RO_ARCHER_ARROW_CRAFT_Poison_L9 = "RO_ARCHER_ARROWCRAFT_PROC_POISON_L9",
    RO_ARCHER_ARROW_CRAFT_Poison_L5 = "RO_ARCHER_ARROWCRAFT_PROC_POISON_L5",
    RO_ARCHER_ARROW_CRAFT_Poison_L3 = "RO_ARCHER_ARROWCRAFT_PROC_POISON_L3",

    RO_ARCHER_ARROW_CRAFT_Shock_L12 = "RO_ARCHER_ARROWCRAFT_PROC_SHOCK_L12",
    RO_ARCHER_ARROW_CRAFT_Shock_L9 = "RO_ARCHER_ARROWCRAFT_PROC_SHOCK_L9",
    RO_ARCHER_ARROW_CRAFT_Shock_L5 = "RO_ARCHER_ARROWCRAFT_PROC_SHOCK_L5",
    RO_ARCHER_ARROW_CRAFT_Shock_L3 = "RO_ARCHER_ARROWCRAFT_PROC_SHOCK_L3",

    RO_ARCHER_ARROW_CRAFT_Radiant_L12 = "RO_ARCHER_ARROWCRAFT_PROC_RADIANT_L12",
    RO_ARCHER_ARROW_CRAFT_Radiant_L9 = "RO_ARCHER_ARROWCRAFT_PROC_RADIANT_L9",
    RO_ARCHER_ARROW_CRAFT_Radiant_L5 = "RO_ARCHER_ARROWCRAFT_PROC_RADIANT_L5",
    RO_ARCHER_ARROW_CRAFT_Radiant_L3 = "RO_ARCHER_ARROWCRAFT_PROC_RADIANT_L3"
}

local ARROWCRAFT_STATUS_PRIORITY = {
    "RO_ARCHER_ARROW_CRAFT_Fire_L12",
    "RO_ARCHER_ARROW_CRAFT_Fire_L9",
    "RO_ARCHER_ARROW_CRAFT_Fire_L5",
    "RO_ARCHER_ARROW_CRAFT_Fire_L3",

    "RO_ARCHER_ARROW_CRAFT_Poison_L12",
    "RO_ARCHER_ARROW_CRAFT_Poison_L9",
    "RO_ARCHER_ARROW_CRAFT_Poison_L5",
    "RO_ARCHER_ARROW_CRAFT_Poison_L3",

    "RO_ARCHER_ARROW_CRAFT_Shock_L12",
    "RO_ARCHER_ARROW_CRAFT_Shock_L9",
    "RO_ARCHER_ARROW_CRAFT_Shock_L5",
    "RO_ARCHER_ARROW_CRAFT_Shock_L3",

    "RO_ARCHER_ARROW_CRAFT_Radiant_L12",
    "RO_ARCHER_ARROW_CRAFT_Radiant_L9",
    "RO_ARCHER_ARROW_CRAFT_Radiant_L5",
    "RO_ARCHER_ARROW_CRAFT_Radiant_L3"
}

local CHARGE_1 = "RO_ARCHER_ARROW_CHARGE_1"
local CHARGE_2 = "RO_ARCHER_ARROW_CHARGE_2"
local CHARGE_3 = "RO_ARCHER_ARROW_CHARGE_3"

local PENDING_TIMEOUT_MS = 3500
local GC_INTERVAL_MS = 1000

local pendingByAction = {}
local processedByAction = {}
local lastGc = 0

local function isNull(uuid)
    return uuid == nil or uuid == "" or uuid == "NULL_00000000-0000-0000-0000-000000000000"
end

local function makeActionKey(source, storyActionId)
    return tostring(source) .. "|" .. tostring(storyActionId)
end

local function getArrowCraftState(character)
    for _, status in ipairs(ARROWCRAFT_STATUS_PRIORITY) do
        local ok, active = pcall(Osi.HasActiveStatus, character, status)
        if ok and active == 1 then
            local procStatus = ARROWCRAFT_STATUS_TO_PROC_STATUS[status]
            if procStatus then
                return status, procStatus
            end
        end
    end

    return nil, nil
end

local function hasAnyCharge(character)
    local ok3, has3 = pcall(Osi.HasActiveStatus, character, CHARGE_3)
    if ok3 and has3 == 1 then return true end

    local ok2, has2 = pcall(Osi.HasActiveStatus, character, CHARGE_2)
    if ok2 and has2 == 1 then return true end

    local ok1, has1 = pcall(Osi.HasActiveStatus, character, CHARGE_1)
    return ok1 and has1 == 1
end

local function clearAllCraftStatuses(character)
    for _, status in ipairs(ARROWCRAFT_STATUS_PRIORITY) do
        pcall(Osi.RemoveStatus, character, status)
    end
end

local function consumeOneCharge(character)
    local ok3, has3 = pcall(Osi.HasActiveStatus, character, CHARGE_3)
    if ok3 and has3 == 1 then
        pcall(Osi.ApplyStatus, character, CHARGE_2, 2.0, 100, character)
        pcall(Osi.RemoveStatus, character, CHARGE_3)
        return true
    end

    local ok2, has2 = pcall(Osi.HasActiveStatus, character, CHARGE_2)
    if ok2 and has2 == 1 then
        pcall(Osi.ApplyStatus, character, CHARGE_1, 2.0, 100, character)
        pcall(Osi.RemoveStatus, character, CHARGE_2)
        return true
    end

    local ok1, has1 = pcall(Osi.HasActiveStatus, character, CHARGE_1)
    if ok1 and has1 == 1 then
        pcall(Osi.RemoveStatus, character, CHARGE_1)
        clearAllCraftStatuses(character)
        return true
    end

    return false
end

Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(caster, target, spell, _, _, storyActionId)
    if isNull(caster) or isNull(target) then
        return
    end

    if not TRACKED_ATTACK_SPELLS[spell] then
        return
    end

    local _, procStatus = getArrowCraftState(caster)
    if not procStatus then
        return
    end

    if not hasAnyCharge(caster) then
        return
    end

    local key = makeActionKey(caster, storyActionId)
    pendingByAction[key] = {
        target = target,
        expiresAt = Ext.Utils.MonotonicTime() + PENDING_TIMEOUT_MS
    }
end)

Ext.Osiris.RegisterListener("AttackedBy", 7, "after", function(defender, attackerOwner, attacker, _, damageAmount, _, storyActionId)
    if damageAmount == nil or damageAmount <= 0 then
        return
    end

    local source = attackerOwner
    if isNull(source) then
        source = attacker
    end

    if isNull(source) or isNull(defender) then
        return
    end

    local key = makeActionKey(source, storyActionId)
    if processedByAction[key] then
        return
    end

    local pending = pendingByAction[key]
    if not pending or pending.target ~= defender then
        return
    end

    processedByAction[key] = Ext.Utils.MonotonicTime() + PENDING_TIMEOUT_MS
    pendingByAction[key] = nil

    local _, procStatus = getArrowCraftState(source)
    if not procStatus or not hasAnyCharge(source) then
        return
    end

    pcall(Osi.RemoveStatus, defender, procStatus)
    pcall(Osi.ApplyStatus, defender, procStatus, 0.5, 100, source)
    consumeOneCharge(source)
end)

Ext.Events.Tick:Subscribe(function()
    local now = Ext.Utils.MonotonicTime()
    if now - lastGc < GC_INTERVAL_MS then
        return
    end

    lastGc = now

    for key, pending in pairs(pendingByAction) do
        if not pending or not pending.expiresAt or now > pending.expiresAt then
            pendingByAction[key] = nil
        end
    end

    for key, expiresAt in pairs(processedByAction) do
        if not expiresAt or now > expiresAt then
            processedByAction[key] = nil
        end
    end
end)
