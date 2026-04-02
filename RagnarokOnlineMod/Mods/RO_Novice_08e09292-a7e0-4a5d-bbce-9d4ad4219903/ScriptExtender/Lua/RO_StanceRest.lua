local STANCE_STATUSES = {
    "RO_ARCHER_OWLS_EYE",
    "RO_ARCHER_VULTURES_EYE",
    "RO_ARCHER_VULTURES_EYE_L5",
    "RO_ARCHER_VULTURES_EYE_L9",
    "RO_ARCHER_VULTURES_EYE_L12"
}

Ext.Osiris.RegisterListener("ShortRested", 1, "after", function(character)
    if not character or character == "" then
        return
    end

    for _, status in ipairs(STANCE_STATUSES) do
        pcall(Osi.RemoveStatus, character, status)
    end
end)
