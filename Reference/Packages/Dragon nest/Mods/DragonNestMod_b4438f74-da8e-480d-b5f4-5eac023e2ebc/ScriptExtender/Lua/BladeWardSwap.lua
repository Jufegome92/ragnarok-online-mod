local MOONLORD_TRAINING_PASSIVE = "DNM_Moonlord_Training"

local SPELL_BLADE_ACTION = "Shout_DNM_BladeWard"
local SPELL_BLADE_BONUS = "Shout_DNM_BladeWard_Survival"

local SPELL_ABSORB_REACTION = "Shout_DNM_AbsorbElements"
local SPELL_ABSORB_ARCANA = "Shout_DNM_AbsorbElements_Arcana"

local SPELL_ENHANCE_DF = "Target_DNM_EnhanceLeap"
local SPELL_ENHANCE_ATHLETICS = "Target_DNM_EnhanceLeap_Athletics"
local LEGACY_SPELL_ENHANCE_DF = "Shout_DNM_EnhanceLeap"
local LEGACY_SPELL_ENHANCE_ATHLETICS = "Shout_DNM_EnhanceLeap_Athletics"

local SPELL_THAUM_DF = "Shout_DNM_Thaumaturgy"
local SPELL_THAUM_INTIMIDATION = "Shout_DNM_Thaumaturgy_Intimidation"

local SPELL_LONGSTRIDER_DF = "Target_DNM_Longstrider"
local SPELL_LONGSTRIDER_ACROBATICS = "Target_DNM_Longstrider_Acrobatics"

local SPELL_MINDSILVER_ACTION = "Target_DNM_MindSilver"
local SPELL_MINDSILVER_INVESTIGATION = "Target_DNM_MindSilver_Investigation"

local trackedCharacters = {}
local appliedBladeWardVariant = {}
local appliedAbsorbVariant = {}
local appliedEnhanceLeapVariant = {}
local appliedThaumaturgyVariant = {}
local appliedLongstriderVariant = {}
local appliedMindSilverVariant = {}
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

local function isMoonlord(character)
    return Osi.HasPassive(character, MOONLORD_TRAINING_PASSIVE) == 1
end

local function hasSkillProficiency(character, skill)
    local abilityBySkill = {
        Survival = "Wisdom",
        Arcana = "Intelligence",
        Athletics = "Strength",
        Intimidation = "Charisma",
        Acrobatics = "Dexterity",
        Investigation = "Intelligence"
    }

    local ability = abilityBySkill[skill]
    if ability == nil then
        return false
    end

    local okSkill, skillValue = pcall(Osi.HasSkill, character, skill)
    if (not okSkill) or type(skillValue) ~= "number" then
        local okFallback, fallbackValue = pcall(Osi.GetSkill, character, skill)
        if not okFallback or type(fallbackValue) ~= "number" then
            return false
        end
        skillValue = fallbackValue
    end

    local abilityScore = Osi.GetAbility(character, ability) or 10
    local abilityModifier = math.floor((abilityScore - 10) / 2)

    -- Proficiency (or expertise) contributes at least +2 above raw ability mod.
    return (skillValue - abilityModifier) >= 2
end

local function ensureSpell(character, spell)
    if Osi.HasSpell(character, spell) == 0 then
        Osi.AddSpell(character, spell, 0, 0)
    end
end

local function removeSpell(character, spell)
    if Osi.HasSpell(character, spell) == 1 then
        Osi.RemoveSpell(character, spell, 1)
    end
end

local function syncSpellLikeVariants(character)
    if character == nil or character == "" then
        return
    end

    if not isMoonlord(character) then
        removeSpell(character, SPELL_BLADE_ACTION)
        removeSpell(character, SPELL_BLADE_BONUS)
        removeSpell(character, SPELL_ABSORB_REACTION)
        removeSpell(character, SPELL_ABSORB_ARCANA)
        removeSpell(character, SPELL_ENHANCE_DF)
        removeSpell(character, SPELL_ENHANCE_ATHLETICS)
        removeSpell(character, LEGACY_SPELL_ENHANCE_DF)
        removeSpell(character, LEGACY_SPELL_ENHANCE_ATHLETICS)
        removeSpell(character, SPELL_THAUM_DF)
        removeSpell(character, SPELL_THAUM_INTIMIDATION)
        removeSpell(character, SPELL_LONGSTRIDER_DF)
        removeSpell(character, SPELL_LONGSTRIDER_ACROBATICS)
        removeSpell(character, SPELL_MINDSILVER_ACTION)
        removeSpell(character, SPELL_MINDSILVER_INVESTIGATION)
        trackedCharacters[character] = nil
        appliedBladeWardVariant[character] = nil
        appliedAbsorbVariant[character] = nil
        appliedEnhanceLeapVariant[character] = nil
        appliedThaumaturgyVariant[character] = nil
        appliedLongstriderVariant[character] = nil
        appliedMindSilverVariant[character] = nil
        return
    end

    trackedCharacters[character] = true

    local wantsBladeBonus = hasSkillProficiency(character, "Survival")
    local wantedBlade = wantsBladeBonus and "bonus" or "action"
    if appliedBladeWardVariant[character] ~= wantedBlade then
        removeSpell(character, SPELL_BLADE_ACTION)
        removeSpell(character, SPELL_BLADE_BONUS)
        if wantsBladeBonus then
            ensureSpell(character, SPELL_BLADE_BONUS)
        else
            ensureSpell(character, SPELL_BLADE_ACTION)
        end
        appliedBladeWardVariant[character] = wantedBlade
    end

    local wantsAbsorbArcana = hasSkillProficiency(character, "Arcana")
    local wantedAbsorb = wantsAbsorbArcana and "arcana" or "reaction"
    local desiredAbsorbSpell = wantsAbsorbArcana and SPELL_ABSORB_ARCANA or SPELL_ABSORB_REACTION
    local otherAbsorbSpell = wantsAbsorbArcana and SPELL_ABSORB_REACTION or SPELL_ABSORB_ARCANA
    if appliedAbsorbVariant[character] ~= wantedAbsorb
        or Osi.HasSpell(character, desiredAbsorbSpell) == 0
        or Osi.HasSpell(character, otherAbsorbSpell) == 1 then
        removeSpell(character, SPELL_ABSORB_REACTION)
        removeSpell(character, SPELL_ABSORB_ARCANA)
        ensureSpell(character, desiredAbsorbSpell)
        appliedAbsorbVariant[character] = wantedAbsorb
    end

    local wantsEnhanceAthletics = hasSkillProficiency(character, "Athletics")
    local wantedEnhance = wantsEnhanceAthletics and "athletics" or "dragonforce"
    if appliedEnhanceLeapVariant[character] ~= wantedEnhance then
        removeSpell(character, SPELL_ENHANCE_DF)
        removeSpell(character, SPELL_ENHANCE_ATHLETICS)
        removeSpell(character, LEGACY_SPELL_ENHANCE_DF)
        removeSpell(character, LEGACY_SPELL_ENHANCE_ATHLETICS)
        if wantsEnhanceAthletics then
            ensureSpell(character, SPELL_ENHANCE_ATHLETICS)
        else
            ensureSpell(character, SPELL_ENHANCE_DF)
        end
        appliedEnhanceLeapVariant[character] = wantedEnhance
    end

    local wantsThaumIntimidation = hasSkillProficiency(character, "Intimidation")
    local wantedThaum = wantsThaumIntimidation and "intimidation" or "dragonforce"
    if appliedThaumaturgyVariant[character] ~= wantedThaum then
        removeSpell(character, SPELL_THAUM_DF)
        removeSpell(character, SPELL_THAUM_INTIMIDATION)
        if wantsThaumIntimidation then
            ensureSpell(character, SPELL_THAUM_INTIMIDATION)
        else
            ensureSpell(character, SPELL_THAUM_DF)
        end
        appliedThaumaturgyVariant[character] = wantedThaum
    end

    local wantsLongstriderAcrobatics = hasSkillProficiency(character, "Acrobatics")
    local wantedLongstrider = wantsLongstriderAcrobatics and "acrobatics" or "dragonforce"
    if appliedLongstriderVariant[character] ~= wantedLongstrider then
        removeSpell(character, SPELL_LONGSTRIDER_DF)
        removeSpell(character, SPELL_LONGSTRIDER_ACROBATICS)
        if wantsLongstriderAcrobatics then
            ensureSpell(character, SPELL_LONGSTRIDER_ACROBATICS)
        else
            ensureSpell(character, SPELL_LONGSTRIDER_DF)
        end
        appliedLongstriderVariant[character] = wantedLongstrider
    end

    local wantsMindSilverInvestigation = hasSkillProficiency(character, "Investigation")
    local wantedMindSilver = wantsMindSilverInvestigation and "investigation" or "action"
    if appliedMindSilverVariant[character] ~= wantedMindSilver then
        removeSpell(character, SPELL_MINDSILVER_ACTION)
        removeSpell(character, SPELL_MINDSILVER_INVESTIGATION)
        if wantsMindSilverInvestigation then
            ensureSpell(character, SPELL_MINDSILVER_INVESTIGATION)
        else
            ensureSpell(character, SPELL_MINDSILVER_ACTION)
        end
        appliedMindSilverVariant[character] = wantedMindSilver
    end
end

local function queueSync(character)
    delayedCall(500, function()
        syncSpellLikeVariants(character)
    end)
end

Ext.Osiris.RegisterListener("GainedControl", 1, "after", function(character)
    trackedCharacters[character] = true
    queueSync(character)
end)

Ext.Osiris.RegisterListener("LeveledUp", 1, "after", function(character)
    trackedCharacters[character] = true
    queueSync(character)
end)

Ext.Osiris.RegisterListener("RespecCompleted", 1, "after", function(character)
    trackedCharacters[character] = true
    queueSync(character)
end)

Ext.Events.Tick:Subscribe(function()
    local now = Ext.Utils.MonotonicTime()
    if now - lastRefresh < refreshIntervalMs then
        return
    end

    lastRefresh = now
    for character, _ in pairs(trackedCharacters) do
        syncSpellLikeVariants(character)
    end
end)
