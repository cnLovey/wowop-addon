-- Create addon namespace
local addonName, addon = ...
-- Localization
local L = wowopLocales

-- Create tables for each region's database if they don't exist
WOWOP_DATABASE_EU = WOWOP_DATABASE_EU or {}
WOWOP_DATABASE_US = WOWOP_DATABASE_US or {}
WOWOP_DATABASE_CN = WOWOP_DATABASE_CN or {}
WOWOP_DATABASE_KR = WOWOP_DATABASE_KR or {}
WOWOP_DATABASE_TW = WOWOP_DATABASE_TW or {}
WOWOP_DATABASE = {}  -- This will hold the active region's database

-- Add this function to load the dungeon database
local function LoadDungeonDatabase()
    -- The database is loaded from database_dungeons.lua into WOWOP_DUNGEON_DATABASE
    if WOWOP_DUNGEON_DATABASE then
        -- Make it available to the addon namespace
        addon.database_dungeons = WOWOP_DUNGEON_DATABASE
        return true
    end
    return false
end

-- Function to determine player's region
local function GetPlayerRegion()
    local region = GetCurrentRegion()
    local regionName
    
    if region == 1 then
        regionName = "US"
    elseif region == 2 then
        regionName = "KR"
    elseif region == 3 then
        regionName = "EU"
    elseif region == 4 then
        regionName = "TW"
    elseif region == 5 then
        regionName = "CN"  
    else
        regionName = "US"
    end
    
    return regionName
end

-- Initialize frame and register events
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

-- Create our custom tooltip frame for LFG applicants
local ApplicantTooltip = CreateFrame("GameTooltip", "WowopApplicantTooltip", UIParent, "GameTooltipTemplate")
ApplicantTooltip:SetClampedToScreen(true)

-- Add these utility functions near the top of the file
local ScrollBoxUtil = {}

function ScrollBoxUtil:OnViewFramesChanged(scrollBox, callback)
    if not scrollBox then
        return
    end
    if scrollBox.buttons then -- legacy support
        callback(scrollBox.buttons, scrollBox)
        return 1
    end
    if scrollBox.RegisterCallback then
        local frames = scrollBox:GetFrames()
        if frames and frames[1] then
            callback(frames, scrollBox)
        end
        scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnUpdate, function()
            frames = scrollBox:GetFrames()
            callback(frames, scrollBox)
        end)
        return true
    end
    return false
end

function ScrollBoxUtil:OnViewScrollChanged(scrollBox, callback)
    if not scrollBox then
        return
    end
    local function wrappedCallback()
        callback(scrollBox)
    end
    if scrollBox.update then -- legacy support
        hooksecurefunc(scrollBox, "update", wrappedCallback)
        return 1
    end
    if scrollBox.RegisterCallback then
        scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnScroll, wrappedCallback)
        return true
    end
    return false
end

local HookUtil = {}

function HookUtil:MapOn(object, map)
    if type(object) ~= "table" then
        return
    end
    if type(object.GetObjectType) == "function" then
        for key, callback in pairs(map) do
            if not object.wowopHooked then
                object:HookScript(key, callback)
                object.wowopHooked = true
            end
        end
        return 1
    end
    for key, callback in pairs(map) do
        for _, frame in pairs(object) do
            if not frame.wowopHooked then
                frame:HookScript(key, callback)
                frame.wowopHooked = true
            end
        end
    end
    return true
end

-- Add this helper function near the top
local function GetObjOwnerName(self)
    local owner, owner_name = self:GetOwner()
    if owner then
        owner_name = owner:GetName()
        if not owner_name then
            owner_name = owner:GetDebugName()
        end
    end
    return owner, owner_name
end

-- Function to get player score
local function GetPlayerScore(playerName, realmName)
    -- If realm is empty, use player's realm
    if not realmName or realmName == "" then
        realmName = GetRealmName()
    end
    
    -- Create the full player-realm key
    local playerKey = playerName .. "-" .. realmName
    
    -- Return the data or nil if not found
    return WOWOP_DATABASE[playerKey]
end

-- Function to get color for score (0-100)
local function GetScoreColor(score)
    if not score then return 1, 1, 1 end -- white for no score
    
    -- Convert hex colors to RGB (0-1 range)
    if score < 25 then
        -- Grey (#666666)
        return 0.4, 0.4, 0.4
    elseif score < 50 then
        -- Green (#1eff00)
        return 0.12, 1, 0
    elseif score < 75 then
        -- Blue (#0070ff)
        return 0, 0.44, 1
    elseif score < 95 then
        -- Epic Purple (#a335ee)
        return 0.64, 0.21, 0.93
    elseif score < 99 then
        -- Orange (#ff8000)
        return 1, 0.5, 0
    elseif score < 100 then
        -- Pink (#e268a8)
        return 0.89, 0.41, 0.66
    else
        -- Gold (#e5cc80)
        return 0.90, 0.80, 0.50
    end
end

-- Function to format score details based on role
local function FormatScoreDetails(scoreDetails, specName)
    if not scoreDetails then return "" end
    
    -- Determine role based on spec name (you might want to maintain a proper spec->role mapping)
    local role = "DPS"
    if specName:match("Restoration") or specName:match("Holy") or specName:match("Discipline") or specName:match("Mistweaver") or specName:match("Preservation") then
        role = "HEALER"
    elseif specName:match("Protection") or specName:match("Blood") or specName:match("Vengeance") or specName:match("Guardian") or specName:match("Brewmaster") then
        role = "TANK"
    end
    
    local lines = {}
    
    -- Format based on role
    if role == "HEALER" then
        if scoreDetails.healing then
            table.insert(lines, string.format(L["Healing: %.1f"], scoreDetails.healing))
        end
        if scoreDetails.damage then
            table.insert(lines, string.format(L["Damage: %.1f"], scoreDetails.damage))
        end
    elseif role == "TANK" then
        if scoreDetails.damage then
            table.insert(lines, string.format(L["Damage: %.1f"], scoreDetails.damage))
        end
        if scoreDetails.deaths then
            table.insert(lines, string.format(L["Survivability: %.1f"], scoreDetails.deaths))
        end
        if scoreDetails.healing then
            table.insert(lines, string.format(L["Self Healing: %.1f"], scoreDetails.healing))
        end
    else -- DPS
        if scoreDetails.damage then
            table.insert(lines, string.format(L["Damage: %.1f"], scoreDetails.damage))
        end
    end
    
    -- Common metrics for all roles
    if scoreDetails.interrupts then
        table.insert(lines, string.format(L["Interrupts: %.1f"], scoreDetails.interrupts))
    end
    if scoreDetails.heavy_fails then
        table.insert(lines, string.format(L["Mechanics: %.1f"], scoreDetails.heavy_fails))
    end
    
    return lines
end

-- Function to add stats to tooltip
local function AddStatsToTooltip(tooltip, name, realm, forceShowAll)
    -- If no realm is specified, use the player's realm
    if not realm or realm == "" then
        realm = GetRealmName()
    end
    
    -- Get the player data
    local playerData = GetPlayerScore(name, realm)
    
    -- Add data to tooltip
    if playerData then
        tooltip:AddLine(" ")  -- Empty line for spacing
        tooltip:AddLine(L["WoWOP.io Stats:"], 0.27, 0.74, 0.98)
        
        -- Add overall score with color
        if playerData.score then
            local r, g, b = GetScoreColor(playerData.score)
            -- Calculate total runs by summing up runs from all specs
            local total_runs = 0
            if playerData.specs then
                for _, specData in pairs(playerData.specs) do
                    total_runs = total_runs + (specData.run_count or 0)
                end
            end
            
            tooltip:AddDoubleLine(
                string.format(L["Overall Score (%d Runs):"], total_runs),
                string.format("%.1f", playerData.score),
                1, 1, 1,  -- white for text
                r, g, b   -- colored score
            )
            
            -- Add karma if it exists and is greater than 0
            if playerData.karma and playerData.karma > 0 then
                tooltip:AddLine(string.format("Karma: +%d", playerData.karma), 0.41, 0.8, 1)  -- Light blue color for karma
            end
        end
        
        -- Show detailed stats when holding shift or when forceShowAll is true
        if IsShiftKeyDown() or forceShowAll then
            if playerData.specs then
                tooltip:AddLine(" ")  -- Spacing
                tooltip:AddLine(L["Spec Scores:"], 0.27, 0.74, 0.98)
                
                for specName, specData in pairs(playerData.specs) do
                    local r, g, b = GetScoreColor(specData.score)
                    -- Show spec name in white, only color the score
                    tooltip:AddDoubleLine(L[specName] .. 
                        string.format(L[" (%d Runs):"], specData.run_count or 0),
                        string.format("%.1f", specData.score), 
                        1, 1, 1,  -- white for spec name
                        r, g, b)  -- colored score
                    
                    -- Add score details if available
                    if specData.score_details then
                        local detailLines = FormatScoreDetails(specData.score_details, specName)
                        for _, line in ipairs(detailLines) do
                            local label, value = line:match("([^:]+): ([%d%.]+)")
                            if label and value then
                                local r, g, b = GetScoreColor(tonumber(value))
                                tooltip:AddDoubleLine(label .. ":", value,
                                    0.8, 0.8, 0.8,  -- Light gray for label
                                    r, g, b)        -- Colored score
                            end
                        end
                    end
                    
                    -- Add bracket scores
                    if specData.brackets then
                        if specData.brackets["8-11"] > 0 then
                            local r, g, b = GetScoreColor(specData.brackets["8-11"])
                            tooltip:AddDoubleLine(L["Bracket 8-11:"], 
                                string.format("%.1f", specData.brackets["8-11"]),
                                1, 1, 1,  -- white for bracket text
                                r, g, b)  -- colored score
                        end
                        if specData.brackets["12-13"] > 0 then
                            local r, g, b = GetScoreColor(specData.brackets["12-13"])
                            tooltip:AddDoubleLine(L["Bracket 12-13:"], 
                                string.format("%.1f", specData.brackets["12-13"]),
                                1, 1, 1,  -- white for bracket text
                                r, g, b)  -- colored score
                        end
                        if specData.brackets["14+"] > 0 then
                            local r, g, b = GetScoreColor(specData.brackets["14+"])
                            tooltip:AddDoubleLine(L["Bracket 14-15:"], 
                                string.format("%.1f", specData.brackets["14+"]),
                                1, 1, 1,  -- white for bracket text
                                r, g, b)  -- colored score
                        end
                    end
                    tooltip:AddLine(" ") -- Add empty line between specs
                end
            end
        else
            -- When not holding shift and not forced, show hint
            tooltip:AddLine(L["Hold SHIFT to show detailed scores"], 0.5, 0.5, 0.5)
        end
        
        tooltip:AddLine(" ")  -- Empty line for spacing
    else
        tooltip:AddLine(" ")  -- Empty line for spacing
        tooltip:AddLine(L["WoWOP.io Stats: N/A"], 0.27, 0.74, 0.98)
        tooltip:AddLine(" ")  -- Empty line for spacing
    end
end

-- Function to handle mouse enter on LFG list items 
local function OnEnter(self)
    if self.applicantID then
        for i = 1, #self.Members do
            local member = self.Members[i]
            local name = member.Name:GetText()
            if name then
                local playerName, realm = name:match("([^-]+)-?(.*)")
                if playerName then
                    GameTooltip:SetOwner(member, "ANCHOR_RIGHT")
                    GameTooltip:AddLine(name)
                    GameTooltip:Show()
                    AddStatsToTooltip(GameTooltip, playerName, realm, true)
                end
            end
        end
    end
end

-- Function to handle mouse leave
local function OnLeave(self)
    GameTooltip:Hide()
    ApplicantTooltip:Hide()
end

-- Function to handle scroll events
local function OnScroll()
    GameTooltip:Hide()
end

-- Hook into all possible tooltip types
local function HookTooltips()
    -- Unit tooltips (nameplates, character frames)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
        local unit = select(2, tooltip:GetUnit())
        if not unit then return end
        
        -- Only show stats for players
        if not UnitIsPlayer(unit) then return end
        
        local name, realm = UnitName(unit)
        if not name then return end
        
        AddStatsToTooltip(tooltip, name, realm)
    end)

    -- LFG tooltips
    hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", function(tooltip, resultID, autoAcceptOption)
        local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
        if not searchResultInfo or not searchResultInfo.leaderName then return end
        
        local name, realm = searchResultInfo.leaderName:match("([^-]+)-?(.*)")
        if name then
            AddStatsToTooltip(tooltip, name, realm, true)
        end
    end)

    -- Guild roster tooltips
    if CommunitiesFrame then
        hooksecurefunc(CommunitiesFrame.MemberList, "RefreshLayout", function()
            local scrollTarget = CommunitiesFrame.MemberList.ScrollBox.ScrollTarget
            if scrollTarget then
                for _, child in ipairs({scrollTarget:GetChildren()}) do
                    if child.NameFrame and not child.wowopHooked then
                        child:HookScript("OnEnter", function(self)
                            if self.memberInfo and self.memberInfo.name then
                                local name, realm = self.memberInfo.name:match("([^-]+)-?(.*)")
                                if name then
                                    if realm == "" then realm = GetRealmName() end
                                    AddStatsToTooltip(GameTooltip, name, realm)
                                    GameTooltip:Show()
                                end
                            end
                        end)
                        child.wowopHooked = true
                    end
                end
            end
        end)
    end

    -- Add LFG frame integration
    if LFGListFrame then
        -- Hook search panel (when looking at groups)
        if LFGListFrame.SearchPanel and LFGListFrame.SearchPanel.ScrollBox then
            local hookMap = { OnEnter = OnEnter, OnLeave = OnLeave }
            ScrollBoxUtil:OnViewFramesChanged(LFGListFrame.SearchPanel.ScrollBox, function(buttons) 
                HookUtil:MapOn(buttons, hookMap)
            end)
            ScrollBoxUtil:OnViewScrollChanged(LFGListFrame.SearchPanel.ScrollBox, OnScroll)
        end

        -- Hook applicant viewer tooltips
        hooksecurefunc(GameTooltip, "SetText", function(self, text)
            local owner, owner_name = GetObjOwnerName(self)
            if not owner or not owner_name then return end
            
            if owner_name:find("LFGListApplicationViewer") or 
               owner_name:find("LFGListFrame.ApplicationViewer") then
                local button = owner
                while button and not button.applicantID do
                    button = button:GetParent()
                end
                
                if button and button.applicantID and owner.memberIdx then
                    local name = C_LFGList.GetApplicantMemberInfo(button.applicantID, owner.memberIdx)
                    if name then
                        local playerName, realm = name:match("([^-]+)-?(.*)")
                        if playerName then
                            AddStatsToTooltip(self, playerName, realm, true)
                        end
                    end
                end
            end
        end)
    end
end

-- Function to load the correct database file
local function LoadRegionDatabase()
    local region = GetPlayerRegion()
    print("WoWOP.io: Loading database for region " .. region)
    
    -- Select the correct database based on region
    local regionDB = _G["WOWOP_DATABASE_" .. region]

    
    if regionDB and next(regionDB) then  -- Check if database exists and is not empty
        WOWOP_DATABASE = regionDB
        local count = 0
        local specCount = 0
        
        -- Count total entries and specs
        for playerKey, playerData in pairs(WOWOP_DATABASE) do
            count = count + 1
            if playerData.specs then
                for _ in pairs(playerData.specs) do
                    specCount = specCount + 1
                end
            end
        end
        
        print(string.format("WoWOP.io: Database loaded with %d players", count))
        
        -- Clear other region databases to free memory
        local regions = {"EU", "US", "CN", "KR", "TW"}
        for _, r in ipairs(regions) do
            if r ~= region then
                _G["WOWOP_DATABASE_" .. r] = nil
                collectgarbage("collect")
            end
        end
        print("WoWOP.io: Cleared unused region databases")
    else
        print("WoWOP.io: WARNING - Database not found for region " .. region .. ", creating empty database")
        WOWOP_DATABASE = {}
    end
end

-- Function to convert realm name to URL format (CamelCase, no spaces)
local function FormatRealmForURL(realm)
    -- If no realm provided, use player's realm
    if not realm or realm == "" then
        realm = GetRealmName()
    end
    
    -- Convert realm name to CamelCase and remove spaces
    return realm:gsub("(%s?)(%w+)(%s?)", function(leading, word, trailing)
        return word:gsub("^%l", string.upper)
    end):gsub("%s+", "")
end

-- Define the popup template
local COPY_URL_POPUP = {
    id = "WOWOP_COPY_URL",
    text = "%s",
    button2 = CLOSE,
    hasEditBox = true,
    hasWideEditBox = true,
    editBoxWidth = 350,
    preferredIndex = 3,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnShow = function(self)
        self:SetWidth(420)
        local editBox = _G[self:GetName() .. "WideEditBox"] or _G[self:GetName() .. "EditBox"]
        editBox:SetText(self.text.text_arg2)
        editBox:SetFocus()
        editBox:HighlightText()
        local button = _G[self:GetName() .. "Button2"]
        button:ClearAllPoints()
        button:SetWidth(200)
        button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end
}

-- Function to show copy URL dialog
local function ShowCopyURLDialog(name, realm)
    -- Format the URL
    local urlRealmName = FormatRealmForURL(realm)
    local region = GetPlayerRegion()
    local url = string.format("https://wowop.io/players/%s/%s?region=%s", urlRealmName, name, region)
    
    if IsModifiedClick("CHATLINK") then
        local editBox = ChatFrame_OpenChat(url, DEFAULT_CHAT_FRAME)
        editBox:HighlightText()
    else
        StaticPopupDialogs[COPY_URL_POPUP.id] = COPY_URL_POPUP
        StaticPopup_Show(COPY_URL_POPUP.id, format("%s (%s)", name, realm), url)
    end
end

-- Add unit dropdown menu option
local function AddUnitDropdownOption()
    -- Function to add our menu items
    local function AddWowopMenuItems(owner, root, contextData)
        local target, server
        
        if contextData and contextData.unit then
            target, server = UnitName(contextData.unit)
        elseif contextData and contextData.name then
            target, server = contextData.name:match("([^-]+)-?(.*)")
        end

        if not target then return end
        
        -- Format the name properly
        if server == nil or server == "" then
            server = GetRealmName()
        end
        
        -- Create our menu items
        root:CreateDivider()
        root:CreateTitle("WoWOP.io")
        root:CreateButton("Copy WoWOP.io URL",
            function(owner, root, contextData)
                ShowCopyURLDialog(target, server)
            end)
    end

    -- Add to various menu types
    Menu.ModifyMenu("MENU_UNIT_PLAYER", AddWowopMenuItems)
    Menu.ModifyMenu("MENU_UNIT_PARTY", AddWowopMenuItems)
    Menu.ModifyMenu("MENU_UNIT_RAID_PLAYER", AddWowopMenuItems)
    Menu.ModifyMenu("MENU_UNIT_ENEMY_PLAYER", AddWowopMenuItems)
    Menu.ModifyMenu("MENU_UNIT_FRIEND", AddWowopMenuItems)
    Menu.ModifyMenu("MENU_UNIT_GUILD", AddWowopMenuItems)
    Menu.ModifyMenu("MENU_UNIT_FOCUS", AddWowopMenuItems)
    Menu.ModifyMenu("MENU_UNIT_TARGET", AddWowopMenuItems)
    Menu.ModifyMenu("MENU_UNIT_SELF", AddWowopMenuItems)
end

-- Function to format player stats for chat output
local function FormatPlayerStats(playerData, playerName)
    if not playerData then return playerName .. L[": No data found"] end
    
    local output = playerName .. L[" - Overall Score: "] .. playerData.score
    if playerData.specs then
        for specName, specData in pairs(playerData.specs) do
            output = output .. "\n  " .. L[specName] .. ": " .. specData.score
            
            -- Add score details if available
            if specData.score_details then
                local role = "DPS"
                if specName:match("Restoration") or specName:match("Holy") or specName:match("Discipline") or 
                   specName:match("Mistweaver") or specName:match("Preservation") then
                    role = "HEALER"
                elseif specName:match("Protection") or specName:match("Blood") or specName:match("Vengeance") or 
                       specName:match("Guardian") or specName:match("Brewmaster") then
                    role = "TANK"
                end
                
                -- Format details based on role with colors
                if role == "HEALER" then
                    if specData.score_details.healing then
                        local r, g, b = GetScoreColor(specData.score_details.healing)
                        output = output .. string.format("\n    Healing: |cff%02x%02x%02x%.1f|r", 
                            r*255, g*255, b*255, specData.score_details.healing)
                    end
                    if specData.score_details.damage then
                        local r, g, b = GetScoreColor(specData.score_details.damage)
                        output = output .. string.format("\n    Damage: |cff%02x%02x%02x%.1f|r", 
                            r*255, g*255, b*255, specData.score_details.damage)
                    end
                elseif role == "TANK" then
                    if specData.score_details.damage then
                        local r, g, b = GetScoreColor(specData.score_details.damage)
                        output = output .. string.format("\n    Damage: |cff%02x%02x%02x%.1f|r", 
                            r*255, g*255, b*255, specData.score_details.damage)
                    end
                    if specData.score_details.deaths then
                        local r, g, b = GetScoreColor(specData.score_details.deaths)
                        output = output .. string.format("\n    Survivability: |cff%02x%02x%02x%.1f|r", 
                            r*255, g*255, b*255, specData.score_details.deaths)
                    end
                    if specData.score_details.healing then
                        local r, g, b = GetScoreColor(specData.score_details.healing)
                        output = output .. string.format("\n    Self Healing: |cff%02x%02x%02x%.1f|r", 
                            r*255, g*255, b*255, specData.score_details.healing)
                    end
                else -- DPS
                    if specData.score_details.damage then
                        local r, g, b = GetScoreColor(specData.score_details.damage)
                        output = output .. string.format("\n    Damage: |cff%02x%02x%02x%.1f|r", 
                            r*255, g*255, b*255, specData.score_details.damage)
                    end
                end
                
                -- Common metrics for all roles
                if specData.score_details.interrupts then
                    local r, g, b = GetScoreColor(specData.score_details.interrupts)
                    output = output .. string.format("\n    Interrupts: |cff%02x%02x%02x%.1f|r", 
                        r*255, g*255, b*255, specData.score_details.interrupts)
                end
                if specData.score_details.heavy_fails then
                    local r, g, b = GetScoreColor(specData.score_details.heavy_fails)
                    output = output .. string.format("\n    Mechanics: |cff%02x%02x%02x%.1f|r", 
                        r*255, g*255, b*255, specData.score_details.heavy_fails)
                end
            end
        end
    end
    return output
end

-- Function to post party stats to party chat
local function PostPartyStats()
    if not IsInGroup() then
        print(L["WoWOP.io: You are not in a group"])
        return
    end
    
    -- Determine the appropriate chat channel
    local channel = IsInRaid() and "RAID" or "PARTY"
    
    -- Post own stats first
    local playerName = UnitName("player")
    local playerData = GetPlayerScore(playerName, GetRealmName())
    if playerData then
        SendChatMessage(L["WoWOP.io Scores:"], channel)
        SendChatMessage(FormatPlayerStats(playerData, playerName), channel)
    end
    
    -- Loop through party/raid members
    local numMembers = IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()
    for i = 1, numMembers do
        local unit = IsInRaid() and "raid"..i or "party"..i
        local name, realm = UnitName(unit)
        if name then
            local playerData = GetPlayerScore(name, realm or GetRealmName())
            if playerData then
                SendChatMessage(FormatPlayerStats(playerData, name), channel)
            end
        end
    end
end

-- Function to lookup player stats from current region
local function LookupPlayerStats(playerFullName)
    if not playerFullName then
        print(L["WoWOP.io: Usage: /wowop lookup playername-realmname"])
        print(L["Example: /wowop lookup Maxxpower-Malygos"])
        return
    end
    
    -- Split the player-realm string (without converting to lowercase)
    local playerName, realmName = strmatch(playerFullName, "([^-]+)-(.+)")
    if not playerName or not realmName then
        print(L["WoWOP.io: Invalid format. Use: playername-realmname"])
        print(L["Example: /wowop lookup Maxxpower-Malygos"])
        return
    end
    
    -- Look up the player in current database
    local playerData = GetPlayerScore(playerName, realmName)
    
    if not playerData then
        print(L["WoWOP.io: No data found for "] .. playerFullName)
        return
    end
    
    -- Print the results
    print(L["WoWOP.io Stats for "] .. playerFullName .. ":")
    
    -- Color the overall score
    local r, g, b = GetScoreColor(playerData.score)
    local coloredScore = string.format("|cff%02x%02x%02x%.1f|r", r*255, g*255, b*255, playerData.score)
    print(L["Overall Score: "] .. coloredScore)
    
    if playerData.specs then
        print(L["Spec Scores:"])
        for specName, specData in pairs(playerData.specs) do
            -- Color the spec score
            local r, g, b = GetScoreColor(specData.score)
            local coloredSpecScore = string.format("|cff%02x%02x%02x%.1f|r", r*255, g*255, b*255, specData.score)
            print("  " .. L[specName] .. ": " .. coloredSpecScore)
            
            -- Add score details if available
            if specData.score_details then
                for metric, value in pairs(specData.score_details) do
                    local r, g, b = GetScoreColor(value)
                    local coloredValue = string.format("|cff%02x%02x%02x%.1f|r", r*255, g*255, b*255, value)
                    print(string.format("    %s: %s", L[metric:gsub("^%l", string.upper)], coloredValue))
                end
            end
            
            -- Color the bracket scores
            if specData.brackets then
                if specData.brackets["8-11"] > 0 then
                    local r, g, b = GetScoreColor(specData.brackets["8-11"])
                    local coloredBracketScore = string.format("|cff%02x%02x%02x%.1f|r", r*255, g*255, b*255, specData.brackets["8-11"])
                    print(L["    Bracket 8-11: "] .. coloredBracketScore)
                end
                if specData.brackets["12-13"] > 0 then
                    local r, g, b = GetScoreColor(specData.brackets["12-13"])
                    local coloredBracketScore = string.format("|cff%02x%02x%02x%.1f|r", r*255, g*255, b*255, specData.brackets["12-13"])
                    print(L["    Bracket 12-13: "] .. coloredBracketScore)
                end
                if specData.brackets["14+"] > 0 then
                    local r, g, b = GetScoreColor(specData.brackets["14+"])
                    local coloredBracketScore = string.format("|cff%02x%02x%02x%.1f|r", r*255, g*255, b*255, specData.brackets["14+"])
                    print(L["    Bracket 14+: "] .. coloredBracketScore)
                end
            end
        end
    end
end

-- Add test command to the existing slash command handler
local function TestDeathAnalysis(spellId)
    if not spellId then
        print(L["Usage: /wowop test <spellId>"])
        return
    end
    
    spellId = tonumber(spellId)
    if not spellId then
        print(L["Invalid spell ID"])
        return
    end
    
    if not WOWOP_DUNGEON_DATABASE then
        print(L["WoWOP.io: Error - Dungeon database not loaded!"])
        return
    end
    
    -- Use the ShowDeathAnalysis function from death_analysis.lua
    addon:TestDeathAnalysis(spellId)
end

-- Update the existing slash command handler
SLASH_WOWOP1 = "/wowop"
SlashCmdList["WOWOP"] = function(msg)
    local command, rest = strmatch(msg, "^(%S*)%s*(.-)%s*$")
    command = command:lower()  -- Only convert the command to lowercase, not the arguments
    
    if command == "" or command == "guide" then
        if addon.ToggleDungeonGuide then
            addon.ToggleDungeonGuide()
        else
            print(L["WoWOP.io: Error - Guide module not loaded properly"])
            print(L["Please report this error to the addon author"])
        end
    elseif command == "post" then
        PostPartyStats()
    elseif command == "lookup" then
        LookupPlayerStats(rest)  -- Pass the rest of the string without converting to lowercase
    elseif command == "test" then
        TestDeathAnalysis(rest)
    else
        print(L["WoWOP.io: Available commands:"])
        print(L["/wowop - Show this help message"])
        print(L["/wowop post - Post group member scores to party/raid chat"])
        print(L["/wowop guide - Open the WoWOP.io Mythic+ Guide"])
        print(L["/wowop lookup Playername-Realm - Look up a player's scores"])
        print(L["/wowop test spellId - Test death analysis for a specific spell"])
    end
end

-- Modify the OnEvent function to ensure database is loaded
local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        LoadRegionDatabase()
        if LoadDungeonDatabase() then
            print(L["WoWOP.io addon loaded!"])
        else
            print(L["WoWOP.io addon loaded, but dungeon database failed to load!"])
        end
        
        -- Hook all tooltips
        HookTooltips()
    end
end

frame:SetScript("OnEvent", OnEvent)
