--Translator--
--__Lovey°--
local Language = GetLocale()

if (Language=="zhCN") then
    wowopLocales = {}

    wowopLocales = {
        --Spec
        --Warrior
        ["Arms"] = "武器", ["Fury"] = "狂怒", ["Protection"] = "防护",
        --Hunter
        ["Beast Mastery"] = "野兽控制", ["Marksmanship"] = "射击", ["Survival"] = "生存",            
        --Mage
        ["Arcane"] = "奥术", ["Fire"] = "火焰", ["Frost"] = "冰霜",
        --Rogue
        ["Assassination"] = "奇袭", ["Outlaw"] = "狂徒", ["Subtlety"] = "敏锐",            
        --Priest
        ["Shadow"] = "暗影", ["Holy"] = "神圣", ["Discipline"] = "戒律",        
        --Warlock
        ["Affliction"] = "痛苦", ["Demonology"] = "恶魔学识", ["Destruction"] = "毁灭",               
        --Paladin
        ["Protection"] = "防护", ["Retribution"] = "惩戒", ["Holy"] = "神圣",
        --Druid
        ["Feral"] = "野性", ["Guardian"] = "守护", ["Balance"] = "平衡", ["Restoration"] = "恢复",
        --Shaman
        ["Elemental"] = "元素", ["Enhancement"] = "增强", ["Restoration"] = "恢复",
        --Monk
        ["Brewmaster"] = "酒仙", ["Windwalker"] = "踏风", ["Mistweaver"] = "织雾",
        --Demon Hunter
        ["Havoc"] = "浩劫", ["Vengeance"] = "复仇",
        --Death Knight
        ["Blood"] = "鲜血", ["Frost"] = "冰霜", ["Unholy"] = "邪恶",
        --Evoker
        ["Devastation"] = "湮灭", ["Preservation"] = "恩护", ["Augmentation"] = "增辉",

        --Tooltips
        ["WoWOP.io Stats:"] = "WoWOP.io 统计:",
        ["Overall Score (%d Runs):"] = "总分 (%d 次记录):",
        ["Spec Scores:"] = "专精分数:",
        [" (%d Runs):"] = " (%d 次记录)",
        ["Bracket 8-11:"] = "钥石范围 8-11:",
        ["Bracket 12-13:"] = "钥石范围 12-13:",
        ["Bracket 14-15:"] = "钥石范围 14-15:",
        ["Hold SHIFT to show detailed scores"] = "按住Shift显示分数明细",
        ["WoWOP.io Stats: N/A"] = "WoWOP.io 统计: 无记录",
        ["Healing: %.1f"] = "治疗: %.1f",
        ["Damage: %.1f"] = "伤害: %.1f",
        ["Survivability: %.1f"] = "生存: %.1f",
        ["Self Healing: %.1f"] = "自疗: %.1f",
        ["Interrupts: %.1f"]  = "打断: %.1f",
        ["Mechanics: %.1f"] = "机制: %.1f",
    
        --command
        ["WoWOP.io: Available commands:"] = "WoWOP.io: 可用命令:",
        ["/wowop - Show this help message"] = "/wowop - 显示此帮助信息",
        ["/wowop post - Post group member scores to party/raid chat"] = "/wowop post - 发送队友分数到小队/团队频道",
        ["/wowop guide - Open the WoWOP.io Mythic+ Guide"] = "/wowop guide - 打开WoWOP.io史诗钥石指南",
        ["/wowop lookup Playername-Realm - Look up a player's scores"] = "/wowop lookup 玩家名-服务器名 - 查看玩家分数",
        ["/wowop test spellId - Test death analysis for a specific spell"] = "/wowop test 法术ID - 对该法术ID的测试死亡分析",
        ["WoWOP.io addon loaded!"] = "WoWOP.io 插件已加载!",
        ["WoWOP.io addon loaded, but dungeon database failed to load!"] = "WoWOP.io 插件已加载,但是副本数据库加载失败!",
        --guide
        ["WoWOP.io: Error - Guide module not loaded properly"] = "WoWOP.io: 错误 - 史诗钥石指南加载失败",
        ["Please report this error to the addon author"] = "请向插件作者报告该错误",
        --post
        ["WoWOP.io: You are not in a group"] = "WoWOP.io: 你不在一个队伍中",
        ["WoWOP.io Scores:"] = "WoWOP.io 分数:",
        [": No data found"] = ": 数据未找到",
        [" - Overall Score: "] = " - 总分: ",
        --lookup
        ["WoWOP.io: Usage: /wowop lookup playername-realmname"] = "WoWOP.io: 用法: /wowop lookup 玩家名-服务器名",
        ["Example: /wowop lookup Maxxpower-Malygos"] = "示例: /wowop lookup 张三-金色平原",
        ["WoWOP.io: Invalid format. Use: playername-realmname"] = "WoWOP.io: 格式错误。使用: 玩家名-服务器名",
        ["WoWOP.io: No data found for "] = "WoWOP.io: 玩家数据未找到-",
        ["WoWOP.io Stats for "] = "WoWOP.io 统计-",
        ["Overall Score: "] = "总分: ",
        --["Spec Scores:"] = "Spec Scores:",
        ["Heavy_fails"] = "重大失误",
        ["Interrupts"] = "打断",
        ["Damage"] = "伤害",
        ["    Bracket 8-11: "] = "    钥石范围 8-11: ",
        ["    Bracket 12-13: "] = "    钥石范围 12-13: ",
        ["    Bracket 14+: "] = "    钥石范围 14+: ",
        --test
        ["Usage: /wowop test <spellId>"] = "用法: /wowop test <法术ID>",
        ["Invalid spell ID"] = "无效的法术ID",
        ["WoWOP.io: Error - Dungeon database not loaded!"] = "WoWOP.io: 错误 - 副本数据库未加载!",

        --Death Analysis

        --Dungeon Guide
    }
end