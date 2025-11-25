IsHost = Ext.Net.IsHost()
-- local Log = Require("Hlib/Log")

Settings = UT.Proxy(
    table.merge({ AutoHide = false, ToggleKey = "U", AutoOpen = true }, IO.LoadJson("ClientConfig.json") or {}),
    function(value, _, raw)
        -- raw not updated yet
        Schedule(function()
            IO.SaveJson("ClientConfig.json", raw)
        end)

        return value
    end
)

Event.On("ToggleDebug", function(bool)
    Mod.Debug = bool
end)

State = {}
Net.On(
    "SyncState",
    Debounce(300, function(event)
        State = event.Payload or {}
        Event.Trigger("StateChange", State)
    end, true)
)

local function RemoveHelperPortraits()
	L.Info("Starting Portrait Function.")
	local rootList = Ext.UI.GetRoot():Find("ContentRoot")
	for i = 1, rootList.ChildrenCount do
		L.Info("Entering Content Root.")
		local node = rootList:Child(i)
		local datalist = node:GetProperty("DataContext")
		if datalist then
			L.Info("Inside Data Context.")
			local combatantList = datalist:GetProperty("Combatants")
			if combatantList then
				L.Info("Inside Combatants List.")
				for i = #combatantList, 1, -1 do
					L.Info("Comparing Combatant ID.")
					if combatantList[i]:GetProperty("CurrentCombatant"):GetProperty("Name") == "heb165bbdgbb0fg4b80gad51gf637bec9bfe9" then
						combatantList[i] = nil
					end
				end
			end
		end
	end
end

Net.On(
	"RemoveHelperPortraits",
	Debounce(100, function(event)
		RemoveHelperPortraits()
	end, true)
)

-- Credit to atamg for this Patch 8 solution for notifications

local FoundNotifRoot

local function Call_Notif(root,data)
    local context = root.DataContext
    context.CurrentSubtitleDuration = data.Duration or 3
    context.CurrentSubtitle = data.Text
end

local function FindUiNotifRoot(root, targetName, path)
    local exportText = Ext.DumpExport(root)
    if exportText:match(targetName) then
        return path
    end
    local has_child = exportText:match("ChildrenCount") ~= nil
--	Log.Debug("Notification Has Child:", has_child)
    local childrenCount = has_child and root.ChildrenCount or 0
--	Log.Debug("Notification Child Count:", childrenCount)
    if childrenCount > 0 then
        for i = 1, childrenCount do
            local child = root:Child(i)
--			Log.Debug("Notification Possible Root:",child)
            local childPath = path .. ":Child(" .. tostring(i) .. ")"
--			Log.Debug("Notification Possible Root Path:", childPath)
            local foundPath = FindUiNotifRoot(child, targetName, childPath)
            if foundPath then
--			    Log.Debug("Notification Path Found:", foundPath)
                return foundPath
            end
        end
    end
    return nil
end

local function LoadString(code)
    local env = {}
    setmetatable(env, { __index = _G })
    local ok, res = pcall(Ext.Utils.LoadString(code, env))
    if not ok then
        error('\n[LoadString]: "' .. code .. '"\n' .. res)
    end
    return res
end

-- No Lib variant
local function Notification(data)
    if not FoundNotifRoot then
        FoundNotifRoot = FindUiNotifRoot(Ext.UI.GetRoot(), "OverheadInfo", "Ext.UI.GetRoot()")
        if FoundNotifRoot then
            Notification(data)
        end
    else
        local Root = LoadString("return " .. FoundNotifRoot)
        if Ext.DumpExport(Root):match("OverheadInfo") then 
--- Hlib variant if get(Root, "XAMLPath", ""):match("OverheadInfo")
            Call_Notif(Root,data)
        else
            FoundNotifRoot = nil
            Notification(data)
        end
    end
end

do
    Net.On("Notification", function(event)

        local data = event.Payload

        Notification(data)
    end)
end

Require("CombatMod/ModActive/Client/GUI/_Init")