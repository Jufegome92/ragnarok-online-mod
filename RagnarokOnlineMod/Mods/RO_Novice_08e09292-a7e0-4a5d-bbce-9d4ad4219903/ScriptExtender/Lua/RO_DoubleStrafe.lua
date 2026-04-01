local FOLLOWUP_BY_SPELL = {
    Projectile_RO_DoubleStrafe = "Projectile_RO_DoubleStrafe_Followup",
    Projectile_RO_DoubleStrafe_5 = "Projectile_RO_DoubleStrafe_Followup_5",
    Projectile_RO_DoubleStrafe_9 = "Projectile_RO_DoubleStrafe_Followup_9",
    Projectile_RO_DoubleStrafe_12 = "Projectile_RO_DoubleStrafe_Followup_12"
}

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

local function isNull(uuid)
    return uuid == nil or uuid == "" or uuid == "NULL_00000000-0000-0000-0000-000000000000"
end

Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(caster, target, spell, _, _, _)
    local followup = FOLLOWUP_BY_SPELL[spell]
    if not followup then
        return
    end

    if isNull(caster) or isNull(target) then
        return
    end

    DelayedCall(60, function()
        pcall(Osi.UseSpell, caster, followup, target, target, 1)
    end)
end)
