---@type Constants
local Constants = Require("Hlib/Constants")

---@class MyConstants : Constants
C = {
    ModUUID = Mod.UUID,
    EnemyFaction = "64321d50-d516-b1b2-cfac-2eb773de1ff6", -- NPC Evil
    NeutralFaction = "cfb709b3-220f-9682-bcfb-6f0d8837462e", -- NPC Neutral
    ShadowCurseTag = "b47643e0-583c-4808-b108-f6d3b605b0a9", -- ACT2_SHADOW_CURSE_IMMUNE
    CompanionFaction = "4abec10d-c2d1-a505-a09a-719c83999847",
    ScenarioHelper = {
        TemplateId = "5ec892d5-9929-4c22-a7a0-0cb6c8a83f20",
        Handle = "hb7387af8g9102g4aabgb7d2g6ddb935e6f65",
        Faction = "4be9261a-e481-8d9d-3528-f36956a19b17",
    },
    MapHelper = "c13a872b-7d9b-4c1d-8c65-f672333b0c11",
    ItemRarity = {
        "Common",
        "Uncommon",
        "Rare",
        "VeryRare",
        "Legendary",
    },
    EnemyTier = {
        "low",
        "mid",
        "high",
        "ultra",
        "epic",
        "legendary",
        "mythical",
        "divine",
		"avatar",
    },
    RoguelikeScenario = "Roguelike",
    LootRates = {
        Objects = {
            Common = 40,
            Uncommon = 20,
            Rare = 10,
            VeryRare = 5,
            Legendary = 2,
        },
        Armor = {
            Common = 30, -- has only junk or invalid items
            Uncommon = 65,
            Rare = 20,
            VeryRare = 10,
            Legendary = 2,
        },
        Weapons = {
            Common = 30, -- has only junk or invalid items
            Uncommon = 65,
            Rare = 20,
            VeryRare = 10,
            Legendary = 2,
        },
    },
	Asylum = {
		Act1 = {
        asylumX = -284.551,
        asylumY = 24.104,
        asylumZ = 116.642,
		},
		Act1b = {
		asylumX = 736.06,
        asylumY = 0,
        asylumZ = -743.228,
		},
		Act2 = {
		asylumX = 55.421,
        asylumY = 0,
        asylumZ = -1407.249,
		},
		Act2b = {
		asylumX = 1154.142,
        asylumY = 0,
        asylumZ = -181.505,
		},
		Act3 = {
		asylumX = 605.245,
        asylumY = 0,
        asylumZ = -750.309,
		},
		Act3b = {
		asylumX = -1565.942,
        asylumY = 0.853,
        asylumZ = 297.384,
		},
		Act3c = {
		asylumX = -1909.747,
        asylumY = -0.232,
        asylumZ = 2675.996,
		},
		Act3i = {
		asylumX = 169.889,
        asylumY = 0,
        asylumZ = 11.882,
		},
	},
}
C = table.merge(Constants, C)
