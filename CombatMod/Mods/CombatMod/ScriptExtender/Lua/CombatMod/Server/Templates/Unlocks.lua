local function getUnlocks()
    return Unlock.Get()
end

local function unlockTadpole(object)
    local e = Ext.Entity.Get(object)
    if not e.Tadpoled then
        e:CreateComponent("Tadpoled")
        e:Replicate("Tadpoled")
    end

    -- give tadpole on first unlock
    if Osi.GetTadpolePowersCount(object) < 1 then
        Osi.AddTadpole(object, 1)
        Osi.AddTadpole(object, 1)
    end

    Osi.SetTag(object, "089d4ca5-2cf0-4f54-84d9-1fdea055c93f")
    Osi.SetTag(object, "efedb058-d4f5-4ab8-8add-bd5e32cdd9cd")
    Osi.SetTag(object, "c15c2234-9b19-453e-99cc-00b7358b9fce")
    Osi.SetTadpoleTreeState(object, 2)
    Osi.AddTadpolePower(object, "TAD_IllithidPersuasion", 1)
    Osi.SetFlag("GLO_Daisy_State_AstralIndividualAccepted_9c5367df-18c8-4450-9156-b818b9b94975", object)
end

local function hagHair()
    local hairs = {}
    local icons = {
        "Item_Quest_HAG_HagHair_Strength",
        "Item_Quest_HAG_HagHair_Dexterity",
        "Item_Quest_HAG_HagHair_Constitution",
        "Item_Quest_HAG_HagHair_Intelligence",
        "Item_Quest_HAG_HagHair_Wisdom",
        "Item_Quest_HAG_HagHair_Charisma",
    }
    for nr, stat in pairs({
        "STR",
        "DEX",
        "CON",
        "INT",
        "WIS",
        "CHA",
    }) do
        local id = "BuyHair" .. stat
        table.insert(hairs, {
            Id = id,
            Name = Localization.Get("hec30ce0dgb76bg45cagaf40gad771ff7902b_" .. nr) .. " +1",
            Icon = icons[nr],
            Cost = 100,
            Amount = 10,
            Character = true,
            OnBuy = function(self, character)
                Osi.ApplyStatus(character, "HAG_HAIR_" .. stat, -1)

                for _, unlock in pairs(getUnlocks()) do
                    if unlock.Id:match("^BuyHair") and unlock.Id ~= id then
                        unlock.Bought = unlock.Bought + 1
                    end
                end
            end,
        })
    end

    return hairs
end

local multis = {
    {
        Id = "MOD_BOOSTS",
        Name = Localization.Get("h911e33dag904ag4b7egb05ag43bea41fbe2b"),
        Icon = "PassiveFeature_Generic_Explosion",
        Cost = 1000,
        Amount = 1,
        Character = false,
        Persistent = false,
        Requirement = 100,
    },
    {
        Id = "ExpMultiplier",
        Name = Localization.Get("hfe5ed56bg3754g4a3dgafa9g70d9759f0a28"),
        Icon = "Spell_MagicJar",
        Cost = 100,
        Amount = 1,
        Character = false,
        Requirement = "MOD_BOOSTS",
        OnBuy = function(self, character)
            PersistentVars.Unlocked.ExpMultiplier = true
        end,
    },
    {
        Id = "LootMultiplier",
        Name = Localization.Get("h982827a7g7b1eg4374g908bgc2a67bf187cc"),
        Icon = "Spell_Transmutation_FleshToGold",
        Cost = 100,
        Amount = 1,
        Character = false,
        Requirement = { "MOD_BOOSTS", 20 },
        OnBuy = function(self, character)
            PersistentVars.Unlocked.LootMultiplier = true
        end,
    },
    {
        Id = "CurrencyMultiplier",
        Name = Localization.Get("h033b172cgdf4bg49b5g831ag3db061ec7174"),
        Icon = "Item_LOOT_COINS_Electrum_Pile_Small_A",
        Cost = 100,
        Amount = 1,
        Character = false,
        Requirement = { "MOD_BOOSTS", 40 },
        OnBuy = function(self, character)
            PersistentVars.Unlocked.CurrencyMultiplier = true
        end,
    },
}

local ngPlus = {
    {
        Id = "QUICKSTART",
        Name = Localization.Get("h99d767f5g0d21g40a7gb1f2g97034979447e"),
		Description = Localization.Get("h9076514cg9b9cg489egb1d7gb7e709f39be9"),
        Icon = "Action_EndGame_NethereseOrbBlast",
        Cost = 2000,
        Amount = 1,
        Character = false,
        Persistent = true,
        Requirement = 300,
    },
    {
        Id = "NG MOD_BOOSTS",
        Name = Localization.Get("h8402b358g3ddeg4eebg9455gce18a891002b"),
        Icon = "PassiveFeature_Generic_Explosion",
        Cost = 0,
        Amount = 1,
        Character = false,
        Persistent = false,
        Requirement = "QUICKSTART",
        OnBuy = function(self, character)
            local unlockBoosts = table.find(Unlock.Get(), function(u)
                return u.Id == "MOD_BOOSTS"
            end)
        unlockBoosts:Buy(character)
        end,
    },
    {
        Id = "BuyRogueScore",
        Name = Localization.Get("ha36188ccg166dg4e87g8dddg67bc3c7a9b46"),
		Description = Localization.Get("h8ad3fa67g955ag492ag8002g2a991761252c"),
        Icon = "GenericIcon_Intent_Buff",
        Cost = 20,
        Amount = nil,
        Character = false,
        Requirement = "QUICKSTART",
        OnBuy = function(self, character)
            GameMode.UpdateRogueScore(PersistentVars.RogueScore + 50)
        end,
    },
    {
        Id = "ScoreMultiplier",
        Name = Localization.Get("h93c6451bg121fg406dga782g17807153dda5"),
        Icon = "GenericIcon_Intent_Buff",
        Cost = 0,
        Amount = 1,
        Character = false,
        Requirement = "QUICKSTART",
        OnBuy = function(self, character)
            PersistentVars.Unlocked.RogueScoreMultiplier = true
        end,
    },
    {
        Id = "CurrencyPlus",
        Name = Localization.Get("h5b24b956gfa5dg4cbdgaf46g9ab930aecb95"),
        Icon = "Item_CONT_GEN_Chest_Rich_B",
        Cost = 0,
        Amount = 1,
        Character = false,
        Requirement = { "QUICKSTART", "ScoreMultiplier" },
        OnBuy = function(self, character)
            PersistentVars.Currency = (PersistentVars.Currency or 0) + 100
        end,
    },
    {
        Id = "BuyExpPlus",
        Name = Localization.Get("h8a656ee4g11bdg46a6ga0a0g295513c20718"),
        Icon = "Action_Dash",
        Cost = 0,
        Amount = 3,
        Character = false,
        Requirement = { "QUICKSTART", "ScoreMultiplier" },
        OnBuy = function(self, character)
            Player.GiveExperience(1000)
        end,
    },
    {
        Id = "BuyLootPlus",
        Name = Localization.Get("h5bb414bag85d4g4f1ega7e5g8bf83b2bd3c1"),
        Icon = "Item_CONT_GEN_Chest_Jewel_A",
        Cost = 0,
        Amount = 10,
        Character = false,
        Requirement = { "QUICKSTART", "ScoreMultiplier" },
        OnBuy = function(self, character)
            local loot = Item.GenerateLoot(10, C.LootRates)

            local x, y, z = Osi.GetPosition(character)
            Item.SpawnLoot(loot, x, y, z)
        end,
    },
    {
        Id = "BuyStockPlus",
        Name = Localization.Get("hd85c346cgca52g4696g836cg41acba4551c2"),
        Icon = "Item_BOOK_SignedTradeVisa",
        Description = Localization.GEt("h444d27cfgdecdg4329g8559g4aceeb256128"),
        Cost = 1000,
        Amount = nil,
        Requirement = { "QUICKSTART" },
        Character = false,
        OnBuy = function(self, character)
            if self.Bought > 0 then
                for _, u in pairs(getUnlocks()) do
                    if
                        string.contains(u.Id, {
                            "^Buy",
                            "TadAwaken",
                        })
                    then
                        if u.Cost > 0 and u.Amount ~= nil and u.Amount > 0 then
                            L.Debug(u.Id)
                            u.Bought = 0
                        end
                    end
                end
            end
        end,
    },
}

--- @type table<number, Unlock>
return table.extend({
    {
        Id = "UnlockTadpole",
        Name = __("Unlock Tadpole Power"),
        Icon = "TadpoleSuperPower_IllithidPowers",
        Cost = 10,
        Requirement = 25,
        Amount = nil,
        Character = true,
        OnBuy = function(self, character)
            unlockTadpole(character)
        end,
    },
    {
        Id = "TadpoleCeremorph",
        Name = Localization.Get("h1d8640a4gb73eg43a7ga61cg640f20536131"),
        Icon = "TadpoleSuperPower_IllithidPersuasion",
        Description = Localization.Get("h92dfe356g7208g4764gaeaag88f551e159bf"),
        Cost = 300,
        Amount = nil,
        Character = true,
        Requirement = 45,
        OnBuy = function(self, character)
            unlockTadpole(character)
            Osi.SetTag(character, "c0cd4ed8-11d1-4fb1-ae3a-3a14e41267c8")
            Osi.ApplyStatus(character, "TAD_PARTIAL_CEREMORPH", -1)
        end,
    },
    {
        Id = "BuyAscension", -- God of Ambition, same as in the base game epilogue, except allowing the user to change equipment
        Name = Localization.Get("h4232ff7cgcfb9g4a22g9443gf87f1019d70e"),
        Icon = "statIcons_GaleGod",
        Description = Localization.Get("h0eef4fd1g0e66g415bg811agd54dcf8adc18"),
        Requirement = 150,
        Cost = 1200,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character) -- Checks to see if recepient is Gale, if Gale Mind Flayer, or other, then gives visually appropriate version of the same buff
            if Osi.HasAppliedStatus(character, "TOT_ASCENSION") ~=1 and Osi.HasAppliedStatus(character, "EPI_GALEGOD") ~=1 then
                if Osi.IsTagged(character, "a3907be6-50c2-407e-b159-8c53f9a3418e") == 1 then
                    if Osi.HasAppliedStatus(character, "MIND_FLAYER_FORM") == 1 then
                        Osi.ApplyStatus(character, "EPI_GALEGOD_MINDFLAYER", -1)
                    else
                        Osi.ApplyStatus(character, "EPI_GALEGOD", -1)
                    end
                elseif Osi.HasAppliedStatus(character, "MIND_FLAYER_FORM") == 1 then
                    Osi.ApplyStatus(character, "TOT_ASCENSION_MINDFLAYER", -1)
                else
                    Osi.ApplyStatus(character, "TOT_ASCENSION", -1)
                end
            end
        end,
    },
    {
        Id = "BuyMindflayerForm",
        Name = Localization.Get("hd58a2099g6c22g499fga7acgab8d6fda5615"),
        Icon = "TadpoleSuperPower_Ceremorphosis",
        Cost = 1500,
        Amount = 1,
        Character = true,
        Requirement = 225,
        OnBuy = function(self, character)
            Osi.ApplyStatus(character, "MIND_FLAYER_FORM", -1)
            -- takes a bit to transform
            WaitTicks(100, function()
                self:OnReapply()
            end)
        end,
        OnReapply = function(self) ---@param self Unlock
            for uuid, _ in pairs(self.BoughtBy) do
                GC.RemoveSpell(uuid, "Target_END_Mindflayer_CrownDomination")
            end
        end,
    },
    {
        Id = "TadAwaken",
        Name = Localization.Get("ha161e914ga226g41c7g971agd92959199ced"),
        Icon = "PassiveFeature_CRE_GithInfirmary_Awakened",
        Description = Localization.Get("h02c55962g989ag4901ga98cg8fcf76a9a120"),
        Cost = 100,
        Requirement = 50,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            Osi.AddPassive(character, "CRE_GithInfirmary_Awakened")
        end,
    },
    {
        Id = "BuyTadInstinct",
        Name = Localization.Get("ha5b687efgdea0g441bg9b23gea473a021ef3"),
        Description = Localization.Get("hcf1ccad1gddf7g447agaf91gf473f16583a0"),
        Icon = "TadpoleSuperPower_SurvivalInstinct",
        Cost = 40,
        Requirement = 50,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            Osi.AddSpell(character, "Target_SurvivalInstinct", 1)
        end,
    },
    {
        Id = "BuyEmperor",
        Name = Localization.Get("hb5358b68ged6bg44e4g9937ga73e425fe42f"),
        Description = Localization.Get("h90c02129gaf64g4a78g99cdg50d209d7af4a"),
        Icon = "TadpoleSuperPower_IllithidExpertise",
        Cost = 300,
        Requirement = 75,
        TemplateId = "1467fb3e-b769-41b1-8207-53e42b5b7aaf",
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            Osi.UseSpell(character, "Target_TOT_Summon_Emperor", character)
            Osi.AddPassive(character, "TOT_EmperorSummoner")
        end,
    },
    {
        Id = "BuyNightsong",
        Name = Localization.Get("hb1600df6gae4ag4718gbc08gf91f423e0e97"),
        Description = Localization.Get("h43f57ae6gaf36g40b2ga036gb0234eed0b71"),
        Icon = "Action_EndGameAlly_NightsongSummon",
        Cost = 300,
        Requirement = 75,
        TemplateId = "4b1ea015-1c6c-4bd4-aff7-ff1b118ca459",
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            Osi.UseSpell(character, "Target_TOT_Summon_Aylin", character)
            Osi.AddPassive(character, "TOT_AylinSummoner")
        end,
    },
    {
        Id = "BuyOwlbear",
        Name = Localization.Get("h8eadfd16g2e13g4590gb62bg633680a154ed"),
        Description = Localization.Get("hd9e32922gc2d9g4589gbc85g5ab127e322f2"),
        Icon = "Action_EndGameAlly_OwlbearCubSummon",
        Cost = 300,
        Requirement = 75,
        TemplateId = "f5d6b4e5-e0ea-44cb-b69b-a52d639cc4c9",
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            Osi.UseSpell(character, "Target_TOT_Summon_Owlbear", character)
            Osi.AddPassive(character, "TOT_OwlbearSummoner")
        end,
    },
    {
        Id = "Tadpole",
        Name = Localization.Get("hd82de71dg534dg4616g8462g2d155883cbdc"),
        Icon = "Item_LOOT_Druid_Autopsy_Set_Tadpole",
        Cost = 30,
        Amount = nil,
        Character = false,
        OnBuy = function(self, character)
            Osi.AddTadpole(character, 1)
        end,
    },
    {
        Id = "BuyExp",
        Name = Localization.Get("hb2f56aafgcdabg40bbgbacag70631cde37ad"),
        Icon = "Action_Dash_Bonus",
        Cost = 40,
        Amount = 4,
        Character = false,
        OnBuy = function(self, character)
            Player.GiveExperience(1000)
        end,
    },
    {
        Id = "BuyLoot",
        Name = Localization.Get("hc1437176g44abg4a53gb5ffg1f5e5b08842c"),
        Icon = "Item_CONT_GEN_Chest_Jewel_B",
        Cost = 30,
        Amount = 10,
        Character = false,
        OnBuy = function(self, character)
            local loot = Item.GenerateLoot(10, C.LootRates)

            local x, y, z = Osi.GetPosition(character)
            Item.SpawnLoot(loot, x, y, z)
        end,
    },
    {
        Id = "BuyLootRare",
        Name = Localization.Get("hb2251e14gb711g4033ga0a1g78198e0b43cd"),
        Icon = "Item_CONT_GEN_Chest_Jewel_C",
        Cost = 50,
        Requirement = 50,
        Amount = 6,
        Character = false,
        OnBuy = function(self, character)
            local loot = Item.GenerateLoot(5, {
                Objects = { Rare = 1 },
                Armor = { Rare = 1 },
                Weapons = { Rare = 1 },
            })

            local x, y, z = Osi.GetPosition(character)
            Item.SpawnLoot(loot, x, y, z)
        end,
    },
    {
        Id = "BuyLootEpic",
        Name = Localization.Get("h58b7b74fg8e45g478ega657g7e96427c6107"),
        Icon = "Item_CONT_GEN_Chest_Jewel_A",
        Cost = 100,
        Requirement = 50,
        Amount = 3,
        Character = false,
        OnBuy = function(self, character)
            local loot = Item.GenerateLoot(3, {
                Objects = { VeryRare = 1 },
                Armor = { VeryRare = 1 },
                Weapons = { VeryRare = 1 },
            })

            local x, y, z = Osi.GetPosition(character)
            Item.SpawnLoot(loot, x, y, z)
        end,
    },
    {
        Id = "BuyLootLegendary",
        Name = Localization.Get("h188e21d6g5551g4745gbfd8g3d08377badc9"),
        Icon = "Item_CONT_GEN_Chest_Jewel_D",
        Cost = 100,
        Requirement = 50,
        Amount = 3,
        Character = false,
        OnBuy = function(self, character)
            local loot = Item.GenerateLoot(1, {
                Objects = { Legendary = 1 },
                Armor = { Legendary = 1 },
                Weapons = { Legendary = 1 },
            })

            local x, y, z = Osi.GetPosition(character)
            Item.SpawnLoot(loot, x, y, z)
        end,
    },
    {
        Id = "BuySupplies",
        Name = Localization.Get("hfb500d01g378eg43abg9b3agff1ade0e4506"),
        Icon = "Item_CONT_GEN_CampSupplySack",
        Cost = 40,
        Amount = nil,
        Character = false,
        OnBuy = function(self, character)
            Osi.PROC_CAMP_GiveFreeSupplies()
        end,
    },
    {
       Id = "ShortRestRecovery",
       Name = Localization.Get("h663f9bc0g9e93g47e4ga6cag2d0ab9d776f7"),
       Description = Localization.Get("hd1272b21g0733g44e7gb599gf46b8bb13322"),
       Icon = "Action_EndGame_IsobelHeal",
       Cost = 250,
       Requirement = 100,
       Amount = 1,
       Character = false,
       OnBuy = function(self, character)
           self:OnInit()
       end,
       Register = U.Once(function(self)
           Ext.Osiris.RegisterListener("ShortRested", 1, "after", function(character)
               local entity = Ext.Entity.Get(character)
               local resources = get(entity.ActionResources, "Resources", {})
               for uuid, list in pairs(resources) do
                   for _, resource in pairs(list) do
                       L.Dump(
                           "Restoring Resource",
                           character,
                           get(Ext.StaticData.Get(resource.ResourceUUID, "ActionResource"), "Name", "Unknown")
                       )
-- Prevent Coffeelocking, otherwise Sorcerer is disproportionately more powerful than all other casters
                       Osi.RemoveStatus(character, "SPELLSLOT_1")
                       Osi.RemoveStatus(character, "SPELLSLOT_2")
                       Osi.RemoveStatus(character, "SPELLSLOT_3")
                       Osi.RemoveStatus(character, "SPELLSLOT_4")
                       Osi.RemoveStatus(character, "SPELLSLOT_5")
                       Osi.RemoveStatus(character, "SORCERYPOINT_1")
                       Osi.RemoveStatus(character, "SORCERYPOINT_2")
                       Osi.RemoveStatus(character, "SORCERYPOINT_3")
                       Osi.RemoveStatus(character, "SORCERYPOINT_4")
                       Osi.RemoveStatus(character, "SORCERYPOINT_5")
                       if resource.ResourceUUID == "d136c5d9-0ff0-43da-acce-a74a07f8d6bf" and resource.Level > math.max(2, math.ceil(Player.Level()/3.3)) then
                           L.Dump(
                           "Spell slot too high level",
                           character,
                           get(Ext.StaticData.Get(resource.ResourceUUID, "ActionResource"), "Name", "Unknown")
                           )
                       elseif resource.ResourceUUID == "46886ba5-6505-4875-a747-ac14118e1e08" then
                           local toRestore = math.max(1, math.ceil(resource.MaxAmount / 2.5))
                           resource.Amount = math.min(Player.Level(), math.floor(resource.Amount + toRestore))
                       else
                           local toRestore = math.max(1, math.ceil(resource.MaxAmount / 2.5))
                           resource.Amount = math.min(resource.MaxAmount, math.floor(resource.Amount + toRestore))
                       end
                   
                   end
               end
               entity:Replicate("ActionResources")
           end)
       end),
       OnInit = function(self)
           if self.Bought > 0 then
               self:Register()
           end
       end,
    },
--    {
--         Id = "BuyRestore",
--         Name = __("Fully Restore Character"),
--         Icon = "Action_EndGame_IsobelHeal",
--         Description = __("Heal character and restore used spells."),
--         Cost = 20,
--         Amount = nil,
--         Character = true,
--         OnBuy = function(self, character)
--              for _, p in pairs(GE.GetParty()) do
--                  Osi.PROC_CharacterFullRestore(p.Uuid.EntityUuid)
--                  Osi.UseSpell(p.Uuid.EntityUuid, "Shout_DivineIntervention_Healing", p.Uuid.EntityUuid)
--              end
--              Osi.PROC_GLO_PartyMembers_TempRestore(character)
--              Osi.PROC_CharacterFullRestore(character)
--              Osi.ApplyStatus(character, "ALCH_POTION_REST_SLEEP_GREATER_RESTORATION", 1)
--        end,
--    },
    {
        Id = "Moonshield",
        Name = Localization.Get("h9fb9cfb8gfde3g435aga3b9g7d9f1c507ab3"),
        Description = Localization.Get("h2eb7e250g6f5dg4c8agaca1gff2104280673"),
        Icon = "statIcons_Moonshield",
        Cost = 30,
        Amount = 1,
        Character = false,
        OnBuy = function(self, character)
            for _, p in pairs(GE.GetParty()) do
                Osi.ApplyStatus(p.Uuid.EntityUuid, "GLO_PIXIESHIELD", -1)
                Osi.SetTag(p.Uuid.EntityUuid, C.ShadowCurseTag)
            end
        end,
        OnReapply = function(self) ---@param self Unlock
            if self.Bought > 0 then
                self:OnBuy()
            end
        end,
    },
    {
        Id = "BreakOath",
        Name = Localization.Get("h3eb286b1g0613g41c9g8f7eg0293b5cfe999"),
        Icon = "statIcons_OathBroken",
        Description = Localization.Get("h6321b88bg0464g4537ga25cgaa37e3cd460d"),
        Cost = 10,
        Amount = nil,
        Character = true,
        OnBuy = function(self, character)
            -- Osi.PROC_GLO_PaladinOathbreaker_BrokeOath(character)
            Osi.PROC_GLO_PaladinOathbreaker_BecomesOathbreaker(character)
            Osi.PROC_GLO_PaladinOathbreaker_RedemptionObtained(character)
            Osi.StartRespecToOathbreaker(character)
        end,
    },
    {
        Id = "BuyGodBlessing",
        Name = Localization.Get("h86fef9afgeb0eg45e8g8388gd8e9f7c619b7"),
        Icon = "GenericIcon_Intent_Buff",
        Description = Localization.Get(
            "he4120ec1gc489g4f2fg947cgbe6449fed394",
            Ext.Stats.Get("LOW_STORMSHORETABERNACLE_GODBLESSED").DescriptionParams
        ), --"Gain Ascendant Bite and Misty Escape (Vampire Ascendant).",), --"Gain +2 bonus to all Saving throws.",
        Cost = 60,
        Requirement = 50,
        Amount = nil,
        Character = true,
        OnBuy = function(self, character)
            Osi.ApplyStatus(character, "LOW_STORMSHORETABERNACLE_GODBLESSED", -1)
        end,
    },
    {
        Id = "BuyLoviatar",
        Name = Localization.Get("h80729873g86d9g4ddbga01egeebe788f1733"),
        Description = Localization.Get("hef31fe63ga576g45c0ga580gf2b0d8fa0b35"),
        Icon = "statIcons_GOB_CalmnessInPain",
        Cost = 40,
        Amount = nil,
        Character = true,
        OnBuy = function(self, character)
            Osi.ApplyStatus(character, "GOB_CALMNESS_IN_PAIN", -1) -- removed on death
        end,
    },
    {
        Id = "BuyScratch",
        Name = Localization.Get("h56b9e3ffg35a9g4593g90fbg44163f03152a"),
        Icon = "Spell_Conjuration_FindFamiliar_Dog",
        Description = Localization.Get("h30de9810g42e4g472bga451g7c5a5fc65c8e"),
        Cost = 40,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            Osi.AddSpell(character, "Target_FindFamiliar_Dog", 1, 0);
            Osi.SetFlag("FOR_Courier_State_CanSummonDog_dded6f0a-25ea-a278-30e1-37d79e4e63c7", character);
        end,
    },
    {
        Id = "BuyIntellectDevourerCompanion",
        Name = Localization.Get("h71c08839ga8ccg45e7g825ag5b57ac274b1e"),
        Icon = "Spell_ConjureUs",
        Description = Localization.Get("h8d833245gf471g4882gb0ddga6f7c58baed3"),
        Cost = 120,
        Requirement = 50,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            Osi.AddSpell(character, "Target_ConjureIntellectDevour", 1, 0);
        end,
    },
    {
        Id = "BuyResonanceStone",
        Name = Localization.Get("h2d9eec26gb99cg4944g9b9bg339dda67c9e2"),
        Icon = "Item_TOOL_MF_Resonance_Crystal_A",
        Description = Localization.Get("hecfe4e23g8a90g4a74g8bc7g5eca34496309"),
        Cost = 120,
        Amount = nil,
        Character = false,
        OnBuy = function(self, character)
            Osi.TemplateAddTo("a7edf7ca-1999-4d2c-b1bf-035d6e2b9e6e", character, 1, 1)
            -- if Osi.HasAppliedStatus(character, "COL_RESONANCESTONE_BUFF") ~= 1 then
            --     Osi.ApplyStatus(character, "COL_RESONANCESTONE_BUFF", -1) -- removed on death
            -- end
        end,
    },
    {
        Id = "BuyAnimateDeadZone",
        Name = Localization.Get("hca33cd78g2509g4736gb3cegc9af2d4faba5"),
        Icon = "PassiveFeature_Generic_Death",
        Description = Localization.Get("he14e8628g1c7fg4e46gadacga197c3410657"),
        Cost = 30,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            Osi.ApplyStatus(character, "ANIMATEDEAD_ZONE", -1)
        end,
        OnReapply = Debounce(100, function(self) ---@param self Unlock
            for uuid, _ in pairs(self.BoughtBy) do
                self:OnBuy(uuid)
            end
        end),
    },
    {
        Id = "BuyFrogMind",
        Name = Localization.Get("hbf05d8a1g044ag4d4aga9ddga01f490d2ed2"),
        Icon = "Item_DEC_MF_Brain_Jar_Memory_A",
        Description = Localization.Get("haed9b6c2g4574g484bg9e1fgd26cf610c63a"),
        Cost = 20,
        Amount = nil,
        Character = true,
        OnBuy = function(self, character)
            Osi.ApplyStatus(character, "COL_GITHZERAI_MIND_TECHNIQUE", -1)
        end,
    },
    {
        Id = "BuyShadowEntangle",
        Name = Localization.Get("hfb295254ga72fg43a6gbab7g14ba7f2fb0fa"),
        Icon = "Spell_Conjuration_Entangled",
        Description = Localization.Get("h9f29e2bbg9d6eg4910g8747ge04cc0468991"),
        Cost = 50,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            Osi.AddSpell(character, "Target_TWN_ArabellaPowers_ShadowEnsnare", 1, 0);
        end,
    },
    {
        Id = "BuyVoloErsatz",
        Name = Localization.Get("h232cc24ega0f9g4f4dgb5d3g46ab59579d4b"),
        Description = Localization.Get("h9d8550edg6d54g4113gbbdcge6d99b8b2a2f"),
        Icon = "Item_DEN_VoloOperation_ErsatzEye",
        Cost = 25,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            Osi.AddPassive(character, "CAMP_Volo_ErsatzEye")
        end,
    },
    {
        Id = "BuyBrand",
        Name = Localization.Get("h7cc7adeag848fg491cga683g0faeaea082c3"),
        Icon = "Item_TOOL_GOB_Branding_Tool_A",
        Description = Localization.Get("h3f06b29fgee73g4fa6g9090g627b22ce2c3f"),
        Cost = 20,
        Amount = 2,
        Character = true,
        OnBuy = function(self, character)
            Osi.SetTag(character, "310f7186-bb0b-4905-b8f6-dfc2fe62570a")
        end,
    },
    {
        Id = "BuyBOOOALBlessing",
        Name = Localization.Get("hc6ac3045g2c16g4d9dgb178gfa9c8c0928b6"),
        Icon = "statIcons_BoooalsBenediction",
        Description = Localization.Get("hf9325d87g8da3g4472g9791gdd55a4bad685"), --"Advantage on Attack rolls against Bleeding cratures.",
        Cost = 50,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            Osi.ApplyStatus(character, "UND_BOOOALBLESSING", -1)
        end,
    },
    {
        Id = "BuyFalseLife",
        Name = Localization.Get("hcb11494cg5afbg4068g8de7g50ccdae27cfe"),
        Icon = "GenericIcon_Intent_Healing",
        Description = Localization.Get("hce17bfdcg2d30g4a97g9850g0219c6a5116a", 20), --"Grants 20 Temporary HP after Long Rest.",
        Cost = 80,
        Requirement = 75,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            Osi.AddPassive(character, "CursedTome_FalseLife")
        end,
    },
    {
        Id = "BuyWakeTheDead",
        Name = Localization.Get("h107871e3gd9c6g4091g828fg3608cb2cb03f"),
        Description = Localization.Get(
            "h0d543bfeg7506g45e8g84fag0350fb67b494",
            Ext.Stats.Get("Target_CursedTome_WakeTheDead").DescriptionParams
        ), --"Gain Ascendant Bite and Misty Escape (Vampire Ascendant).",
        Icon = "Spell_WakeTheDead",
        Cost = 80,
        Requirement = 100,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            Osi.AddSpell(character, "Target_CursedTome_WakeTheDead", 1)
        end,
    },
    {
        Id = "BuyVampireAscendant",
        Name = Localization.Get("h7c8ce380g0d56g4807gb60cg58e283b4ecdb"),
        Icon = "Action_Monster_Bulette_Bite",
        Description = Localization.Get(
            "hf9a3c136gfa53g4170g9eeega20ced9c9111",
            Ext.Stats.Get("LOW_Astarion_VampireAscendant").DescriptionParams
        ), --"Gain Ascendant Bite and Misty Escape (Vampire Ascendant).",
        Cost = 300,
        Requirement = 75,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            Osi.AddPassive(character, "LOW_Astarion_VampireAscendant")
        end,
    },
    {
        Id = "BuyBloodyInheritance",
        Name = Localization.Get("hc4d08908g6040g4e50g889cg0ef6e267b6e0"),
        Icon = "PassiveFeature_Generic_Blood",
        Description = Localization.Get("h473ffdccgc70fg4761gaa67gbf0fb07d475f"), --"Gain Stunning Gaze and Critical Hit requirement reduced by 2.",
        Cost = 100,
        Requirement = 75,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            if Osi.HasAppliedStatus(character, "END_ALLYABILITIES_BHAALBUFF") ~= 1 then
                Osi.ApplyStatus(character, "END_ALLYABILITIES_BHAALBUFF", -1)
            end
        end,
        OnReapply = Debounce(100, function(self) ---@param self Unlock
            for uuid, _ in pairs(self.BoughtBy) do
                self:OnBuy(uuid)
            end
        end),
    },
    {
        Id = "BuySweetStoneFeatures",
        Name = Localization.Get("h9d318df0g739eg4313gbc3cgc77a3afc702e"),
        Icon = "Spell_Enchantment_Bless",
        Description = Localization.Get("h0be556d1g0e1bg48ddg9ce4g86d3891c06e2"),
        Cost = 150,
        Requirement = 75,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            if Osi.HasAppliedStatus(character, "WYR_CIRCUS_STATUEBLESS") ~= 1 then
                Osi.ApplyStatus(character, "WYR_CIRCUS_STATUEBLESS", -1)
            end
        end,
        OnReapply = Debounce(100, function(self) ---@param self Unlock
            for uuid, _ in pairs(self.BoughtBy) do
                self:OnBuy(uuid)
            end
        end),
    },
    {
        Id = "BuyVolosGuide",
        Name = Localization.Get("h397d3e3fgf2c3g4f5cg8974g7784ef35cc21"),
        Icon = "PassiveFeature_PactOfTheTome",
        Description = Localization.Get("h8cbbf143ga45cg4547ga745g215e06edd50a"),
        Cost = 400,
        Requirement = 150,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            if Osi.HasAppliedStatus(character, "END_ALLYBUFF_VOLO") ~= 1 then
                Osi.ApplyStatus(character, "END_ALLYBUFF_VOLO", -1)
            end
        end,
        OnReapply = Debounce(100, function(self) ---@param self Unlock
            for uuid, _ in pairs(self.BoughtBy) do
                self:OnBuy(uuid)
            end
        end),
    },
    {
        Id = "BuyThanielBuff",
        Name = Localization.Get("h221a4b23g1fe7g4c43g834bg2863ae271223"),
        Icon = "statIcons_Momentum",
        Description = Localization.Get("hf21573f5g0d33g4acaga833ge2ecab662902"),
        Cost = 275,
        Requirement = 150,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            if Osi.HasAppliedStatus(character, "END_ALLYBUFF_HALSIN") ~= 1 then
                Osi.ApplyStatus(character, "END_ALLYBUFF_HALSIN", -1)
            end
        end,
        OnReapply = Debounce(100, function(self) ---@param self Unlock
            for uuid, _ in pairs(self.BoughtBy) do
                self:OnBuy(uuid)
            end
        end),
    },
    {
        Id = "BuyMolBuff",
        Name = Localization.Get("hd6eee16fgaf11g483bgb572g1923ad837611"),
        Icon = "Action_Monster_Cambion_FireRay",
        Description = Localization.Get("ha6f6614cg0ab1g44e4gaf1eg00b3e01c1a23"),
        Cost = 350,
        Requirement = 150,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            if Osi.HasAppliedStatus(character, "END_ALLYABILITIES_MOLBUFF") ~= 1 then
                Osi.ApplyStatus(character, "END_ALLYABILITIES_MOLBUFF", -1)
            end
        end,
        OnReapply = Debounce(100, function(self) ---@param self Unlock
            for uuid, _ in pairs(self.BoughtBy) do
                self:OnBuy(uuid)
            end
        end),
    },
    {
        Id = "BuyArabellaBuff",
        Name = Localization.Get("hcec0f370geccfg445egaf70g1974159ff90b"),
        Icon = "Spell_Abjuration_FreedomOfMovement",
        Description = Localization.Get("h0439851dgc0a2g49f6g9714gfcf1e4557edd"),
        Cost = 350,
        Requirement = 150,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            if Osi.HasAppliedStatus(character, "END_ALLYABILITIES_ARABELLABUFF") ~= 1 then
                Osi.ApplyStatus(character, "END_ALLYABILITIES_ARABELLABUFF", -1)
            end
        end,
        OnReapply = Debounce(100, function(self) ---@param self Unlock
            for uuid, _ in pairs(self.BoughtBy) do
                self:OnBuy(uuid)
            end
        end),
    },
    {
        Id = "BuySlayer",
        Name = Localization.Get("h7ee059fega56bg48d4g99abg0a1ee50238d1"),
        Description = Localization.Get("h67dd3fb6ge300g42f0gaea3g0ecb374132c7", 10),
        Icon = "Action_DarkUrge",
        Requirement = 75,
        Cost = 200,
        Amount = 1,
        Character = true,
        OnBuy = function(self, character)
            Osi.AddSpell(character, "Shout_DarkUrge_Slayer", 1)
            Osi.SetTag(character, "f09707c1-7c58-4611-a06b-ce34dd2826c6")
        end,
    },
}, multis, hagHair(), ngPlus)
