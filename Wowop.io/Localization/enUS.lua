local Language = GetLocale()

--if (Language=="enUS") then
    wowopLocales = {}

    wowopLocales = {
        --Spec
        --Warrior
        ["Arms"] = "Arms", ["Fury"] = "Fury", ["Protection"] = "Protection",
        --Hunter
        ["Beast Mastery"] = "Beast Mastery", ["Marksmanship"] = "Marksmanship", ["Survival"] = "Survival",            
        --Mage
        ["Arcane"] = "Arcane", ["Fire"] = "Fire", ["Frost"] = "Frost",
        --Rogue
        ["Assassination"] = "Assassination", ["Outlaw"] = "Outlaw", ["Subtlety"] = "Subtlety",            
        --Priest
        ["Shadow"] = "Shadow", ["Holy"] = "Holy", ["Discipline"] = "Discipline",        
        --Warlock
        ["Affliction"] = "Affliction", ["Demonology"] = "Demonology", ["Destruction"] = "Destruction",               
        --Paladin
        ["Protection"] = "Protection", ["Retribution"] = "Retribution", ["Holy"] = "Holy",
        --Druid
        ["Feral"] = "Feral", ["Guardian"] = "Guardian", ["Balance"] = "Balance", ["Restoration"] = "Restoration",
        --Shaman
        ["Elemental"] = "Elemental", ["Enhancement"] = "Enhancement", ["Restoration"] = "Restoration",
        --Monk
        ["Brewmaster"] = "Brewmaster", ["Windwalker"] = "Windwalker", ["Mistweaver"] = "Mistweaver",
        --Demon Hunter
        ["Havoc"] = "Havoc", ["Vengeance"] = "Vengeance",
        --Death Knight
        ["Blood"] = "Blood", ["Frost"] = "Frost", ["Unholy"] = "Unholy",
        --Evoker
        ["Devastation"] = "Devastation", ["Preservation"] = "Preservation", ["Augmentation"] = "Augmentation",

        --Tooltips
        ["WoWOP.io Stats:"] = "WoWOP.io Stats:",
        ["Overall Score (%d Runs):"] = "Overall Score (%d Runs):",
        ["Spec Scores:"] = "Spec Scores:",
        [" (%d Runs):"] = " (%d Runs):",
        ["Bracket 8-11:"] = "Bracket 8-11:",
        ["Bracket 12-13:"] = "Bracket 12-13:",
        ["Bracket 14-15:"] = "Bracket 14-15:",
        ["Hold SHIFT to show detailed scores"] = "Hold SHIFT to show detailed scores",
        ["WoWOP.io Stats: N/A"] = "WoWOP.io Stats: N/A",
        ["Healing: %.1f"] = "Healing: %.1f",
        ["Damage: %.1f"] = "Damage: %.1f",
        ["Survivability: %.1f"] = "Survivability: %.1f",
        ["Self Healing: %.1f"] = "Self Healing: %.1f",
        ["Interrupts: %.1f"]  = "Interrupts: %.1f",
        ["Mechanics: %.1f"] = "Mechanics: %.1f",

        --command
        ["WoWOP.io: Available commands:"] = "WoWOP.io: Available commands:",
        ["/wowop - Show this help message"] = "/wowop - Show this help message",
        ["/wowop post - Post group member scores to party/raid chat"] = "/wowop post - Post group member scores to party/raid chat",
        ["/wowop guide - Open the WoWOP.io Mythic+ Guide"] = "/wowop guide - Open the WoWOP.io Mythic+ Guide",
        ["/wowop lookup Playername-Realm - Look up a player's scores"] = "/wowop lookup Playername-Realm - Look up a player's scores",
        ["/wowop test spellId - Test death analysis for a specific spell"] = "/wowop test spellId - Test death analysis for a specific spell",
        ["WoWOP.io addon loaded!"] = "WoWOP.io addon loaded!",
        ["WoWOP.io addon loaded, but dungeon database failed to load!"] = "WoWOP.io addon loaded, but dungeon database failed to load!",
        --guide
        ["WoWOP.io: Error - Guide module not loaded properly"] = "WoWOP.io: Error - Guide module not loaded properly",
        ["Please report this error to the addon author"] = "Please report this error to the addon author",
        --post
        ["WoWOP.io: You are not in a group"] = "WoWOP.io: You are not in a group",
        ["WoWOP.io Scores:"] = "WoWOP.io Scores:",
        [": No data found"] = ": No data found",
        [" - Overall Score: "] = " - Overall Score: ",
        --lookup
        ["WoWOP.io: Usage: /wowop lookup playername-realmname"] = "WoWOP.io: Usage: /wowop lookup playername-realmname",
        ["Example: /wowop lookup Maxxpower-Malygos"] = "Example: /wowop lookup Maxxpower-Malygos",
        ["WoWOP.io: Invalid format. Use: playername-realmname"] = "WoWOP.io: Invalid format. Use: playername-realmname",
        ["WoWOP.io: No data found for "] = "WoWOP.io: No data found for ",
        ["WoWOP.io Stats for "] = "WoWOP.io Stats for ",
        ["Overall Score: "] = "Overall Score: ",
        --["Spec Scores:"] = "Spec Scores:",
        ["Heavy_fails"] = "Heavy_fails",
        ["Interrupts"] = "Interrupts",
        ["Damage"] = "Damage",
        ["    Bracket 8-11: "] = "    Bracket 8-11: ",
        ["    Bracket 12-13: "] = "    Bracket 12-13: ",
        ["    Bracket 14+: "] = "    Bracket 14+: ",
        --test
        ["Usage: /wowop test <spellId>"] = "Usage: /wowop test <spellId>",
        ["Invalid spell ID"] = "Invalid spell ID",
        ["WoWOP.io: Error - Dungeon database not loaded!"] = "WoWOP.io: Error - Dungeon database not loaded!",
        
        --Death Analysis

        --Dungeon Guide
    }
--end