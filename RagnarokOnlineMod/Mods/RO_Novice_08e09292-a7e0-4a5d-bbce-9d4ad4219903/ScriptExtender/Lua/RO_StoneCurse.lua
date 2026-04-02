local CRUMBLING_STATUS = "RO_MAGICIAN_STONECURSE_CRUMBLING"
local PROC_STATUS = "RO_MAGICIAN_STONECURSE_CRUMBLING_HIT"
local PROC_GUARD_STATUS = "RO_MAGICIAN_STONECURSE_CRUMBLING_PROC_GUARD"

local function isNull(uuid)
    return uuid == nil or uuid == "" or uuid == "NULL_00000000-0000-0000-0000-000000000000"
end

local function hasStatus(entity, status)
    local ok, active = pcall(Osi.HasActiveStatus, entity, status)
    return ok and active == 1
end

local function isPhysicalDamageType(damageType)
    if damageType == nil then
        return false
    end

    local dt = string.lower(tostring(damageType))
    return dt == "slashing" or dt == "piercing" or dt == "bludgeoning"
end

Ext.Osiris.RegisterListener("AttackedBy", 7, "after", function(defender, attackerOwner, attacker, damageType, damageAmount, _, _)
    if isNull(defender) then
        return
    end

    if damageAmount == nil or damageAmount <= 0 then
        return
    end

    if not isPhysicalDamageType(damageType) then
        return
    end

    if not hasStatus(defender, CRUMBLING_STATUS) then
        return
    end

    if hasStatus(defender, PROC_GUARD_STATUS) then
        return
    end

    local source = attackerOwner
    if isNull(source) then
        source = attacker
    end

    if isNull(source) then
        return
    end

    -- Guard prevents recursion when the proc damage itself triggers AttackedBy.
    pcall(Osi.ApplyStatus, defender, PROC_GUARD_STATUS, 0.4, 100, source)
    pcall(Osi.ApplyStatus, defender, PROC_STATUS, 0.1, 100, source)
end)