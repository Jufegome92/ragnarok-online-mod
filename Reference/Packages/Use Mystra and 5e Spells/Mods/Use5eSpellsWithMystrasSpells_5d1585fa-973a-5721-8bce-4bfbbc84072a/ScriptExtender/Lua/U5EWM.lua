local levelKeys = {
    "Cantrips",
    "1st Level Spells",
    "2nd Level Spells",
    "3rd Level Spells",
    "4th Level Spells",
    "5th Level Spells",
    "6th Level Spells",
    "7th Level Spells",
    "8th Level Spells",
    "9th Level Spells",
}

local classKeys = {
    "Ritual Caster Feat",
    "Spell Sniper Attack",
    "Bard",
    "Bard Magical Secrets",
    "Cleric",
    "Druid",
    "Fighter Eldritch Knight",
    "Paladin",
    "Ranger",
    "Rogue Arcane Tricker",
    "Sorcerer",
    "Warlock",
    "Warlock Archfey",
    "Warlock Fiend",
    "Warlock The Great Old One",
    "Warlock Hexblade",
    "Wizard",
}

local targetLists = {
    ["Ritual Caster Feat"] = {
        ["1st Level Spells"] = "8c32c900-a8ea-4f2f-9f6f-eccd0d361a9d",
    },
    ["Spell Sniper Attack"] = {
        ["Cantrips"] = "64784e08-e31e-4850-a743-ecfb3fd434d7",
    },
    Bard = {
        ["Cantrips"] = "61f79a30-2cac-4a7a-b5fe-50c89d307dd6",
        ["1st Level Spells"] = "dcb45167-86bd-4297-9b9d-c295be51af5b",
        ["2nd Level Spells"] = "7ea8f476-97a1-4256-8f10-afa76a845cce",
        ["3rd Level Spells"] = "c213ca01-3767-457b-a5c8-fd4c1dd656e2",
        ["4th Level Spells"] = "75e04c40-be8f-40a5-9acc-0b5d59d5f3a6",
        ["5th Level Spells"] = "bd71fffb-e4d2-4233-9a31-13d43fba36e3",
        ["6th Level Spells"] = "586a8796-34f4-41f5-a3ef-95738561d55d",
        ["7th Level Spells"] = "f923e058-b1d9-4b02-98ef-9daaa82a71b6",
        ["8th Level Spells"] = "073c09e5-ccb9-4153-a210-001225a30cbb",
        ["9th Level Spells"] = "2bbd99d0-21b4-41cc-836e-e386a96fc8e6",
    },
    ["Bard Magical Secrets"] = {
        ["3rd Level Spells"] = "175ceed7-5a53-4f48-823c-41c4f72d18ae",
        ["5th Level Spells"] = "858d4322-9e9f-4aa4-aada-9c68835dc6fe",
        ["7th Level Spells"] = "95f80109-32b7-43f8-a99a-7ee2286a993a",
        ["9th Level Spells"] = "cd83187f-c886-45c2-be81-34083981f240",
    },
    Cleric = {
        ["Cantrips"] = "2f43a103-5bf1-4534-b14f-663decc0c525",
        ["1st Level Spells"] = "269d1a3b-eed8-4131-8901-a562238f5289",
        ["2nd Level Spells"] = "2968a3e6-6c8a-4c2e-882a-ad295a2ad8ac",
        ["3rd Level Spells"] = "21be0992-499f-4c7a-a77a-4430085e947a",
        ["4th Level Spells"] = "37e9b20b-5fd1-45c5-b1c5-159c42397c83",
        ["5th Level Spells"] = "b73aeea5-1ff9-4cac-b61d-b5aa6dfe31c2",
        ["6th Level Spells"] = "f8ba7b05-1237-4eaa-97fa-1d3623d5862b",
        ["7th Level Spells"] = "11862b36-c2d6-4d2f-b2d7-4af29f8fe31a",
        ["8th Level Spells"] = "a0df1e32-1c61-4017-939f-44cc7695a924",
        ["9th Level Spells"] = "9ea2891d-f0f9-42d0-b13d-7f1a5df154c3",
    },
    Druid = {
        ["Cantrips"] = "b8faf12f-ca42-45c0-84f8-6951b526182a",
        ["1st Level Spells"] = "2cd54137-2fe5-4100-aad3-df64735a8145",
        ["2nd Level Spells"] = "92126d17-7f1a-41d2-ae6c-a8d254d2b135",
        ["3rd Level Spells"] = "3156daf5-9266-41d0-b52c-5bc559a98654",
        ["4th Level Spells"] = "09c326c9-672c-4198-a4c0-6f07323bde27",
        ["5th Level Spells"] = "ff711c12-b59f-4fde-b9ea-6e5c38ec8f23",
        ["6th Level Spells"] = "6a4e2167-55f3-4ba8-900f-14666b293e93",
        ["7th Level Spells"] = "29c9cf78-3bd6-47dc-88b4-2dce54710124",
        ["8th Level Spells"] = "bdff0cba-d631-4b83-9562-63c0187df380",
        ["9th Level Spells"] = "9e388f0f-7432-4f29-bfe5-5358ebde4491",
    },
    ["Fighter Eldritch Knight"] = {
        ["Cantrips"] = "6529c75a-d8cd-4ddb-a1b1-f55cb1e66d9f",
        ["1st Level Spells"] = "32aeba85-13bd-4a6f-8e06-cd4447b746d8",
        ["2nd Level Spells"] = "4a86443c-6a21-4b8d-b1bf-55a99e021354",
        ["3rd Level Spells"] = "9ca503db-0e4b-4325-b1eb-e2f794a075d6",
        ["4th Level Spells"] = "5798e5a8-da36-40bc-acf5-2b736cf607a2",
    },
    Paladin = {
        ["1st Level Spells"] = "c6288ac5-c68b-40ed-bbdd-2ff388575831",
        ["2nd Level Spells"] = "c14c9564-1503-47a1-be19-98e77f22ff59",
        ["3rd Level Spells"] = "d18dec04-478f-41c3-b816-239d5cfcf2a2",
        ["4th Level Spells"] = "11d0c2a0-41c6-4ec0-98fe-5d987f7e1665",
        ["5th Level Spells"] = "f351595c-90f7-4804-9e55-18c4d624593c",
    },
    Ranger = {
        ["1st Level Spells"] = "458be063-60d4-4548-ae7d-50117fa0226f",
        ["2nd Level Spells"] = "e7cfb80a-f5c2-4304-8446-9b00ea6a9814",
        ["3rd Level Spells"] = "9a60f649-7f82-4152-90b1-0499c5c9f3e2",
        ["4th Level Spells"] = "7022d937-b2e4-4b6e-a3c5-e168f5c00194",
        ["5th Level Spells"] = "412d77e1-4aa2-4149-aa0e-c835b8c79f32",
    },
    ["Rogue Arcane Tricker"] = {
        ["1st Level Spells"] = "4b629bbb-203b-4382-9786-755bf897567f",
        ["2nd Level Spells"] = "f9fd64f1-f417-4544-94a9-51d8876d68df",
        ["3rd Level Spells"] = "c707cc1f-e5ed-4798-909a-3652ad497d24",
        ["4th Level Spells"] = "0329cc67-3e67-409c-9b22-fb510a564c98",
    },
    Sorcerer = {
        ["Cantrips"] = "485a68b4-c678-4888-be63-4a702efbe391",
        ["1st Level Spells"] = "92c4751f-6255-4f67-822c-a75d53830b27",
        ["2nd Level Spells"] = "f80396e2-cb76-4694-b0db-5c34da61a478",
        ["3rd Level Spells"] = "dcbaf2ae-1f45-453e-ab83-cd154f8277a4",
        ["4th Level Spells"] = "5fe40622-1d3e-4cc1-8d89-e66fe51d8c5c",
        ["5th Level Spells"] = "3276fcfe-e143-4559-b6e0-7d7aa0ffcb53",
        ["6th Level Spells"] = "1270a6db-980b-4e3b-bf26-2924da61dfd5",
        ["7th Level Spells"] = "9e38e5ae-51e8-4dd4-aad5-869a571b1519",
        ["8th Level Spells"] = "5a8a002c-352b-44e9-8233-da7e6112f4b0",
        ["9th Level Spells"] = "d58ac072-e079-410b-b167-a5e43723b59f",
    },
    Warlock = {
        ["Cantrips"] = "f5c4af9c-5d8d-4526-9057-94a4b243cd40",
        ["6th Level Spells"] = "e6ccab5e-3b3b-4b34-8fa2-1058dff2b3e6",
        ["7th Level Spells"] = "388cd3b0-914a-44b6-a828-1315323b9fd7",
        ["8th Level Spells"] = "070495e1-ccf4-4c05-9add-61c5010b8204",
        ["9th Level Spells"] = "47766c27-e791-4e6e-9b3d-2bb379106e62",
    },
    ["Warlock Archfey"] = {
        ["1st Level Spells"] = "e0099b15-2599-4cba-a54b-b25ae03d6519",
        ["2nd Level Spells"] = "0cc2c8ab-9bbc-43a7-a66d-08e47da4c172",
        ["3rd Level Spells"] = "f18ad912-e2f4-47a9-8744-73d6a51c2941",
        ["4th Level Spells"] = "c3d8a4a5-9dae-4193-8322-a5d1c5b89f47",
        ["5th Level Spells"] = "0a9b924f-64fb-4f22-b975-5eeedc99b2fd",
    },
    ["Warlock Fiend"] = {
        ["1st Level Spells"] = "4823a292-f584-4f7f-8434-6630c72e5411",
        ["2nd Level Spells"] = "835aeca7-c64a-4aaa-a25c-143aa14a5cec",
        ["3rd Level Spells"] = "5dec41aa-f16a-434e-b209-50c07e64e4ed",
        ["4th Level Spells"] = "7ad7dbd0-751b-4bcd-8034-53bcc7bfb19d",
        ["5th Level Spells"] = "deab57bf-4eec-4085-82f7-87335bce3f5d",
    },
    ["Warlock The Great Old One"] = {
        ["1st Level Spells"] = "65952d48-bb16-4ad7-b173-532182bf7770",
        ["2nd Level Spells"] = "fe101a94-8619-49b2-859d-a68c2c291054",
        ["3rd Level Spells"] = "30e9b761-6be0-418e-bb28-5103c00c663b",
        ["4th Level Spells"] = "b64e527e-1f97-4125-84f7-78376ab1440b",
        ["5th Level Spells"] = "6d2edca9-71a7-4f3f-89f0-fccfff0bdee5",
    },
    ["Warlock Hexblade"] = {
        ["1st Level Spells"] = "d90e88eb-e5f9-4db2-b7ef-1dccb044839a",
        ["2nd Level Spells"] = "4a3bf687-91c1-4dad-821c-ad32171c7552",
        ["3rd Level Spells"] = "58b8c82e-8ab3-4fd7-aa0a-3f2b831187f5",
        ["4th Level Spells"] = "39750075-781e-4ce2-a033-f8a288e47b8e",
        ["5th Level Spells"] = "88fafaeb-8b59-4319-9841-b9e6043f4636",
    },
    Wizard = {
        ["Cantrips"] = "3cae2e56-9871-4cef-bba6-96845ea765fa",
        ["1st Level Spells"] = "11f331b0-e8b7-473b-9d1f-19e8e4178d7d",
        ["2nd Level Spells"] = "80c6b070-c3a6-4864-84ca-e78626784eb4",
        ["3rd Level Spells"] = "22755771-ca11-49f4-b772-13d8b8fecd93",
        ["4th Level Spells"] = "820b1220-0385-426d-ae15-458dc8a6f5c0",
        ["5th Level Spells"] = "f781a25e-d288-43b4-bf5d-3d8d98846687",
        ["6th Level Spells"] = "bc917f22-7f71-4a25-9a77-7d2f91a96a65",
        ["7th Level Spells"] = "dff7917a-0abc-4671-b68f-c03e56212549",
        ["8th Level Spells"] = "f27a2d0a-0d6c-4c01-98a5-60081abf4807",
        ["9th Level Spells"] = "cb123d97-8809-4d71-a0cb-0ecb66177d15",
    },
}

local duplicatedSpellsLists = {
    ["Cantrips"] = {
        "Target_BoomingBladeMove", "Projectile_Infestation", "Projectile_MindSilver", "Target_CreateDestroyMoldEarth",
        "Target_ShapeWater_Container", "Shout_MagicStone",
    },
    ["1st Level Spells"] = {
        "Shout_AbsorbElementsSpell", "Projectile_ChaosBoltNew", "Zone_CausticBrew",
    },
    ["2nd Level Spells"] = {
        "Zone_AganazzarScorcher", "Shout_DustDevil", "Target_EarthenGrasp", "Target_SnowballStorm", "Target_MindWhip",
    },
    ["3rd Level Spells"] = {
        "Shout_CreateFoodAndWater", "Shout_MelfsMinuteMeteors", "Target_SummonFey", "Shout_WaterWalk",
    },
    ["4th Level Spells"] = {
        "Target_ArcaneEyeNew", "Target_PsychicLance", "Target_SummonBeholderkin",
    },
    ["5th Level Spells"] = {
        "Shout_FarStep", "Target_SteelWindStrike", "Target_SummonDraconicSpirit",
    },
    ["6th Level Spells"] = {},
    ["7th Level Spells"] = {},
    ["8th Level Spells"] = {},
    ["9th Level Spells"] = {},
}

local function InTable(list, val)
    if list ~= nil then
        for _, v in pairs(list) do
            if v == val then
                return true
            end
        end
    end
    return false
end

local function SubtractLists(list1, list2)
    local result = {}
    local num = 1
    if list1 ~= nil then
        for _, v in pairs(list1) do
            if not InTable(list2, v) then
                result[num] = v
                num = num + 1
            end
        end
    end
    return result
end

local function MergeLists(list1, list2)
    local result = {}
    local num = 1
    if list1 ~= nil then
        for _, v in pairs(list1) do
            if not InTable(result, v) then
                result[num] = v
                num = num + 1
            end
        end
    end
    if list2 ~= nil then
        for _, v in pairs(list2) do
            if not InTable(result, v) then
                result[num] = v
                num = num + 1
            end
        end
    end
    return result
end

local function RemoveDuplicatedSpells()
    local prevDuplicatedSpellsLists = {}
    for _, level in ipairs(levelKeys) do
        local duplicatedSpellsList = duplicatedSpellsLists[level]

        if level ~= "Cantrips" then
            duplicatedSpellsList = MergeLists(duplicatedSpellsList, prevDuplicatedSpellsLists)
            prevDuplicatedSpellsLists = duplicatedSpellsList
        end

        if #duplicatedSpellsList > 0 then
            for _, class in ipairs(classKeys) do
                local targetUUID = targetLists[class] and targetLists[class][level]

                if targetUUID then
                    local targetList = Ext.StaticData.Get(targetUUID, "SpellList")

                    if targetList then
                        local cleanedSpells = SubtractLists(targetList["Spells"], duplicatedSpellsList)
                        targetList["Spells"] = cleanedSpells
                    end
                end
            end
        end
        print(string.format("Use 5eSpells with Mystra's Spells: " .. level .. " have been cleaned."))
    end
end

local function U5EWM_StatsLoaded()
    RemoveDuplicatedSpells()
end

Ext.Events.StatsLoaded:Subscribe(U5EWM_StatsLoaded)
