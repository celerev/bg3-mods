-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                            Public                                           --
--                                                                                             --
-------------------------------------------------------------------------------------------------

---@param userId number|nil
---@return string GUID of the host character
function Player.Host(userId)
    if userId then
        local player = Osi.GetCurrentCharacter(userId)

        if player then
            return player
        end
    end

    return Osi.GetHostCharacter()
end

---@return string region
function Player.Region()
    return Osi.GetRegion(Player.Host())
end

---@return number x, number y, number z
function Player.Pos()
    return Osi.GetPosition(Player.Host())
end

function Player.Level()
    return GE.GetHost().EocLevel.Level
end

---@param character string|nil GUID
---@return string|nil GUID
function Player.InCombat(character)
    return table.find(GU.DB.GetPlayers(), function(guid)
        return (character == nil or U.UUID.Equals(guid, character)) and Osi.IsInCombat(guid) == 1
    end)
end

---@param character string|nil GUID
---@return string|nil GUID
function Player.InCamp(character)
    return table.find(GU.DB.GetPlayers(), function(guid)
        return (character == nil or U.UUID.Equals(guid, character)) and Ext.Entity.Get(guid).CampPresence ~= nil
    end)
end

---@param character string|nil GUID
---@return boolean
function Player.IsPlayer(character)
    return table.find(GU.DB.GetPlayers(), function(uuid)
        return U.UUID.Equals(character, uuid)
    end) ~= nil
end

function Player.PartySize()
    local party = table.filter(GU.DB.GetPlayers(), function(guid)
        return Osi.CanJoinCombat(guid) == 1
    end)

    return math.max(1, #party)
end

function Player.DisplayName(character)
    local p = Ext.Entity.Get(character or Player.Host())

    if p.CustomName then
        return p.CustomName.Name
    end

    return Localization.Get(p.DisplayName.NameKey.Handle.Handle)
end

local buffering = {}
function Player.Notify(message, instant, ...)
    L.Info("Notify:", message, ...)
    Net.Send("PlayerNotify", { message, ... })

    if Config.TurnOffNotifications then
        return
    end

    local id = U.RandomId("Notify_")

    if instant then
        table.insert(buffering, 1, id)
    else
        table.insert(buffering, id)
    end
    local function remove()
        for i, v in ipairs(buffering) do
            if v == id then
                table.remove(buffering, i)
                break
            end
        end
    end

    RetryUntil(function()
        return buffering[1] == id
    end, { retries = 30, interval = 300 }):After(function()
        Net.Send("Notification", { Duration = 3, Text = message })
        Defer(1000, remove)
    end):Catch(remove)
end

---@param act string
---@return ChainableRunner|nil
local teleporting = false
function Player.TeleportToAct(act)
    if teleporting then
        return
    end
    if act == "Act3i" then
        Osi.TeleportPartiesToLevelWithMovie("IRN_Main_A", "", "")
        Osi.DB_Debug_RestoringAct("Act3b","IRN_Main_A")
        teleporting = true
    else
        Osi.PROC_Debug_TeleportToAct(act)
        teleporting = true
    end

    local didUnload = false
    local function checkUnload()
        if didUnload then
            GameState.OnLoad(function()
                teleporting = false
            end, true)
        else
            teleporting = false
        end
    end

    local handler = GameState.OnUnload(function()
        didUnload = true
        checkUnload()
    end, true)

    Defer(3000, function()
        handler:Unregister()

        if not didUnload then
            checkUnload()
        end
    end)

    return WaitUntil(function()
        return not teleporting
    end):After(function()
        Event.Trigger("TeleportedToAct", act)

        return true
    end)
end

function Player.TeleportToRegion(region)
    for act, reg in pairs(C.Regions) do
        if reg == region then
            return Player.TeleportToAct(act)
        end
    end
end

function Player.TeleportToCamp()
    local activeCamp = GU.DB.TryGet("DB_ActiveCamp", 1, nil, 1)[1]
    if activeCamp == nil then
        L.Error("No active camp found.")
        return
    end

    local campEntry = GU.DB.TryGet("DB_Camp", 4, { activeCamp }, 3)[1]
    local campEntryFallback = GU.DB.TryGet("DB_Camp", 4, { activeCamp }, 2)[1]
    if not campEntry then
        L.Error("No camp trigger found.")
        return
    end

    for _, entity in pairs(GE.GetParty()) do
        L.Debug("TeleportToCamp", entity.Uuid.EntityUuid, campEntry, campEntryFallback)
        if not entity.CampPresence then
            if campEntry then
                Osi.TeleportTo(entity.Uuid.EntityUuid, campEntry, "", 1, 1, 1, 1, 1)
                Osi.PROC_Camp_TeleportToCamp(entity.Uuid.EntityUuid, campEntry)
            end
            if campEntryFallback then
                Osi.TeleportTo(entity.Uuid.EntityUuid, campEntryFallback, "", 1, 1, 1, 1, 1)
                Osi.PROC_Camp_TeleportToCamp(entity.Uuid.EntityUuid, campEntryFallback)
            end

            if Osi.IsDead(entity.Uuid.EntityUuid) == 1 and Config.AutoResurrect and Osi.HasActiveStatus(entity.Uuid.EntityUuid, "ATT_IMPLOSIONDEATH") == 0 then
                Osi.Resurrect(entity.Uuid.EntityUuid)
                Osi.EndTurn(entity.Uuid.EntityUuid)
            end
        end
    end
end

function Player.ReturnToCamp()
    Event.Trigger("ReturnToCamp")

    if Player.Region() == "END_Main" or Player.Region() == "INT_Main_A" then
        -- If we just came from Netherbrain or Wyrm's Lookout, we need to clear flags preventing Long Rest
        Osi.ClearFlag("END_BrainBattle_Event_Started_3cd63c2e-7343-45dd-9137-4cabca2179a6", "NULL_00000000-0000-0000-0000-000000000000", 0)
        Osi.ClearFlag("END_General_State_CurrentlyInBrainBattle_0d7205b2-0d55-4540-8737-543253873cd6", "NULL_00000000-0000-0000-0000-000000000000", 0)
        Osi.PROC_END_BrainBattle_ClearBrainBattle()
        Osi.ClearFlag("END_General_State_Started_a0fd5f91-e4b3-4d01-84d3-9ff484139e99", "NULL_00000000-0000-0000-0000-000000000000", 0)
		Osi.DB_INT_EmperorRevealed_WeakToAbsolute:Delete(1)
        Osi.DB_Camp_Unlocked(1)
        Osi.SetLongRestAvailable(1)
        Osi.PROC_Foop("S_GLO_JergalAvatar_0133f2ad-e121-4590-b5f0-a79413919805")
        Osi.SetTag("S_GLO_JergalAvatar_0133f2ad-e121-4590-b5f0-a79413919805", "TRADER_91d5ebc6-91ea-44db-8a51-216860d69b5b")
        Osi.PROC_GLO_Jergal_SetDialog("CAMP_Jergal_7f4acd9b-15c0-81fe-9409-623634ec3ed3")

        Osi.PROC_GLO_Jergal_MoveToCamp()
        Osi.PROC_GLO_Jergal_Appear()

        Osi.SetJoinBlock(0)


        for _, player in pairs(GU.DB.GetPlayers()) do
            Osi.SetIsInDangerZone(player, 0)
            Osi.PROC_SetBlockDismiss(player, 0)
            Osi.DB_InDangerZone:Delete(player, "ENDGAME")

           if player == C.OriginCharactersStarter.Karlach then
               Osi.DB_OriginInPartyDialog(C.OriginCharactersStarter.Karlach, "Karlach_InParty_12459660-b66e-9b0b-9963-670e0993543d")
           elseif player == C.OriginCharactersStarter.Gale then
               Osi.DB_OriginInPartyDialog(C.OriginCharactersStarter.Gale, "Gale_InParty_6beb1b10-845f-49fa-6d6d-f425eaa42574")
           elseif player == C.OriginCharactersStarter.Astarion then
               Osi.DB_OriginInPartyDialog(C.OriginCharactersStarter.Astarion,"Astarion_InParty_53aba16e-55bb-a0fc-a444-522e237dbe46")
           elseif player == C.OriginCharactersStarter.Laezel then
               Osi.DB_OriginInPartyDialog(C.OriginCharactersStarter.Laezel, "Laezel_InParty_93bf58f5-5111-9730-1ee2-62dfb0b00c96")
           elseif player == C.OriginCharactersStarter.Wyll then
               Osi.DB_OriginInPartyDialog(C.OriginCharactersStarter.Wyll, "Wyll_InParty_6dff0a1f-1a51-725d-6e9a-52b5742ba9e6")
           elseif player == C.OriginCharactersStarter.ShadowHeart then
               Osi.DB_OriginInPartyDialog(C.OriginCharactersStarter.ShadowHeart, "ShadowHeart_InParty_95ca3833-09d0-5772-b16a-c7a5e9208fe5")
           elseif player == C.OriginCharactersSpecial.Halsin then
               Osi.DB_OriginInPartyDialog(C.OriginCharactersSpecial.Halsin, "Halsin_InParty_890c2586-6b71-ca01-5bd6-19d533181c71")
           elseif player == C.OriginCharactersSpecial.Minthara then
               Osi.DB_OriginInPartyDialog(C.OriginCharactersSpecial.Minthara, "Minthara_InParty_13d72d55-0d47-c280-9e9c-da076d8876d8")
               Osi.SetFaction(C.OriginCharactersSpecial.Minthara, C.CompanionFaction)
           elseif player == C.OriginCharactersSpecial.Jaheira then
               Osi.DB_PermaDefeated:Delete(C.OriginCharactersSpecial.Jaheira)
               Osi.ClearTag(C.OriginCharactersSpecial.Jaheira, "BLOCK_RESURRECTION_22a75dbb-1588-407e-b559-5aa4e6d4e6a6")
               Osi.SetHasDialog(C.OriginCharactersSpecial.Jaheira, 1)
               Osi.DB_OriginInPartyDialog(C.OriginCharactersSpecial.Jaheira, "Jaheira_InParty_e97481ba-961c-50a7-c54f-d34d6b75044d")
           elseif player == C.OriginCharactersSpecial.Minsc then
               Osi.DB_OriginInPartyDialog(C.OriginCharactersSpecial.Minsc, "Minsc_InParty_d0554ced-ca60-938b-362c-07b0c77610d7")
           elseif player == C.OriginCharactersSpecial.Alfira then
               Osi.DB_OriginInPartyDialog(C.OriginCharactersSpecial.Alfira, "DEN_Bard_InParty_3c71c397-b378-340b-0da9-ef3d17d14423")
           end
        end

        -- act 1 seems to load fastest
        return Player.TeleportToAct("act1"):After(function()
            Player.TeleportToCamp()
            return true
        end)
    end

    Osi.DB_Camp_Unlocked(1)
    Osi.SetLongRestAvailable(1)

    Osi.PROC_GLO_Jergal_MoveToCamp()
    Osi.PROC_GLO_Jergal_Appear()

    Osi.SetJoinBlock(0)

    for _, player in pairs(GU.DB.GetPlayers()) do
        Osi.SetIsInDangerZone(player, 0)
        Osi.PROC_SetBlockDismiss(player, 0)
        Osi.DB_InDangerZone:Delete(player, "ENDGAME")
    end

    if Player.Region() == "IRN_Main_A" then
        return Player.TeleportToAct("act1"):After(function()
            Player.TeleportToCamp()
            return true
        end)
    end

    Player.TeleportToCamp()

    return Schedule()
end

local readyChecks = {}
---@class ChainableConfirmation : Chainable
---@field After fun(func: fun(result: boolean): any): Chainable
---@param message string
---@return ChainableConfirmation
function Player.AskConfirmation(message, ...)
    message = __(message, ...)
    local msgId = U.RandomId("AskConfirmation_")
    Osi.ReadyCheckSpecific(msgId, message, 1, Player.Host(), "", "", "")

    local chainable = Libs.Chainable(message)
    readyChecks[msgId] = function(...)
        chainable:Begin(...)
    end

    return chainable
end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                           Events                                            --
--                                                                                             --
-------------------------------------------------------------------------------------------------

Ext.Osiris.RegisterListener("ReadyCheckPassed", 1, "after", function(id)
    L.Debug("ReadyCheckPassed", id)
    if readyChecks[id] then
        local func = readyChecks[id]
        readyChecks[id] = nil
        func(true)
    end
end)

Ext.Osiris.RegisterListener("ReadyCheckFailed", 1, "after", function(id)
    L.Debug("ReadyCheckFailed", id)
    if readyChecks[id] then
        local func = readyChecks[id]
        readyChecks[id] = nil
        func(false)
    end
end)
