---@diagnostic disable: undefined-global

---@type Mod
local Mod = Require("Shared/Mod")

---@type Constants
local Constants = Require("Shared/Constants")

---@class Utils
local M = {}

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                           Generic                                           --
--                                                                                             --
-------------------------------------------------------------------------------------------------

---@param v1 any
---@param v2 any
---@param ignoreMT boolean|nil ignore metatables
function M.Equals(v1, v2, ignoreMT)
    if v1 == v2 then
        return true
    end

    local v1Type = type(v1)
    local v2Type = type(v2)
    if v1Type ~= v2Type then
        return false
    end
    if v1Type ~= "table" then
        return false
    end

    if not ignoreMT then
        local mt1 = getmetatable(v1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return v1 == v2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(v1) do
        local value2 = v2[key1]
        if value2 == nil or M.Equals(value1, value2, ignoreMT) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(v2) do
        if not keySet[key2] then
            return false
        end
    end

    return true
end

-- probably useless
function M.Random(...)
    local time = Ext.Utils.MonotonicTime()
    local rand = Ext.Math.Random(...)
    local args = { ... }

    if #args == 0 then
        local r1 = math.floor(rand * time)
        local r2 = math.ceil(rand * time)
        rand = Ext.Math.Random(r1, r2) / time
        return rand
    end

    if #args == 1 then
        args[2] = args[1]
        args[1] = 1
    end

    rand = Ext.Math.Random(args[1] + rand * time, args[2] + rand * time) / time
    return Ext.Math.Round(rand)
end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                           Entity                                            --
--                                                                                             --
-------------------------------------------------------------------------------------------------

M.Entity = {}

---@return string[] list of avatar characters
function M.Entity.GetAvatars()
    return M.Table.Map(M.Protected.TryGetDB("DB_Avatars", 1), function(v)
        return v[1]
    end)
end

---@return string[] list of playable characters
function M.Entity.GetPlayers()
    return M.Table.Map(M.Protected.TryGetDB("DB_Players", 1), function(v)
        return v[1]
    end)
end

---@param character string GUID
---@return boolean
function M.Entity.IsHireling(character)
    local faction = Osi.GetFaction(character)

    return faction:match("^Hireling") ~= nil
end

---@param character string GUID
---@return boolean
function M.Entity.IsOrigin(character)
    local faction = Osi.GetFaction(character)

    local UUIDChar = M.UUID.GetGUID(character)

    return faction:match("^Origin") ~= nil
        or faction:match("^Companion") ~= nil
        or (
            #M.Table.Filter(Constants.OriginCharacters, function(v)
                return M.UUID.Equals(v, UUIDChar)
            end) > 0
        )
end

---@param character string GUID
---@param ignoreParty boolean|nil Summons or QuestNPCs might be considered party members
---@return boolean
function M.Entity.IsNonPlayer(character, ignoreParty)
    if ignoreParty and (Osi.IsPartyMember(character, 1) == 1 or Osi.IsPartyFollower(character) == 1) then
        return false
    end
    return not M.Entity.IsOrigin(character) and not M.Entity.IsHireling(character) and Osi.IsPlayer(character) == 0
end

---@param character string GUID
---@return boolean
function M.Entity.IsPlayable(character)
    return M.Entity.IsOrigin(character)
        or M.Entity.IsHireling(character)
        or Osi.IsPlayer(character) == 1
        or (
            M.Table.Find(M.Entity.GetAvatars(), function(v)
                return M.UUID.Equals(v, character)
            end) ~= nil
        )
end

-- also works for items
function M.Entity.Remove(guid)
    Osi.SetOnStage(guid, 0)
    Osi.TeleportToPosition(guid, 0, 0, 0, "", 1, 1, 1, 1, 0) -- no blood
    Osi.RequestDelete(guid)
    Osi.Die(guid, 2, "NULL_00000000-0000-0000-0000-000000000000", 0, 1)
end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                           Table                                             --
--                                                                                             --
-------------------------------------------------------------------------------------------------

M.Table = {}

---@param t1 table
---@vararg table
---@return table<string, any>
function M.Table.Merge(t1, ...)
    for _, t2 in ipairs({ ... }) do
        for k, v in pairs(t2) do
            t1[k] = v
        end
    end
    return t1
end

---@param t1 table<number, any>
---@vararg table
---@return table<number, any>
function M.Table.Combine(t1, ...)
    local r = {}
    for _, t in ipairs({ t1, ... }) do
        for _, v in pairs(t) do
            table.insert(r, v)
        end
    end
    return r
end

function M.Table.Size(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

---@param t table<number, any> e.g. { 1, 2, 3 } or { {v=1}, {v=2}, {v=3} }
---@param remove any|table<number, any> e.g. 2 or {v=2}
---@param multiple boolean|nil remove is a table of remove e.g. { 2, 3 } or { {v=2}, {v=3} }
---@return table t
function M.Table.Remove(t, remove, multiple)
    for i = #t, 1, -1 do
        if multiple then
            for _, value in ipairs(remove) do
                if M.Equals(t[i], value, true) then
                    table.remove(t, i)
                    break
                end
            end
        else
            if M.Equals(t[i], remove, true) then
                table.remove(t, i)
            end
        end
    end
    return t
end

---@param t table
---@param seen table|nil used to prevent infinite recursion
---@return table
function M.Table.DeepClone(t, seen)
    -- Handle non-tables and previously-seen tables.
    if type(t) ~= "table" then
        return t
    end
    if seen and seen[t] then
        return seen[t]
    end

    -- New table; mark it as seen and copy recursively.
    local s = seen or {}
    local res = {}
    s[t] = res
    for k, v in pairs(t) do
        res[M.Table.DeepClone(k, s)] = M.Table.DeepClone(v, s)
    end
    return setmetatable(res, getmetatable(t))
end

---@param t table
---@param func function @function(value, key) -> value: any|nil, key: any|nil
---@return table
function M.Table.Map(t, func)
    local r = {}
    for k, v in pairs(t) do
        local value, key = func(v, k)
        if value ~= nil then
            if key ~= nil then
                r[key] = value
            else
                table.insert(r, value)
            end
        end
    end
    return r
end

---@param t table
---@param func function @function(value, key) -> boolean
---@return table
function M.Table.Filter(t, func, keepKeys)
    return M.Table.Map(t, function(v, k)
        if func(v, k) then
            if keepKeys then
                return v, k
            else
                return v
            end
        end
    end)
end

---@param t table table to search
---@param v any value to search for
---@param count boolean|nil return count instead of boolean
---@return boolean|number
function M.Table.Contains(t, v, count)
    local r = #M.Table.Filter(t, function(v2)
        return v == v2
    end)
    return count and r or r > 0
end

---@param t table table to search
---@param func function @function(value, key) -> boolean
---@return any|nil, string|number|nil @value, key
function M.Table.Find(t, func)
    for k, v in pairs(t) do
        if func(v, k) then
            return v, k
        end
    end
    return nil, nil
end

---@param t table
---@return table
function M.Table.Keys(t)
    return M.Table.Map(t, function(_, k)
        return k
    end)
end

---@param t table
---@return table
function M.Table.Values(t)
    return M.Table.Map(t, function(v)
        return v
    end)
end

---@param t table<number, string>
---@return table<string, number>
function M.Table.Set(t)
    return M.Table.Map(t, function(v, k)
        return k, tostring(v)
    end)
end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                           String                                            --
--                                                                                             --
-------------------------------------------------------------------------------------------------

M.String = {}

-- same as string.match but case insensitive
function M.String.IMatch(s, pattern, init)
    s = string.lower(s)
    pattern = string.lower(pattern)
    return string.match(s, pattern, init)
end

function M.String.MatchAfter(s, prefix)
    return string.match(s, prefix .. "(.*)")
end

---@param s string
---@param patterns string[]|string
---@param ignoreCase boolean|nil
---@return boolean
function M.String.Contains(s, patterns, ignoreCase)
    if type(patterns) == "string" then
        patterns = { patterns }
    end
    for _, pattern in ipairs(patterns) do
        if ignoreCase then
            return M.String.IMatch(s, pattern) ~= nil
        end
        return string.match(s, pattern) ~= nil
    end
    return false
end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                          Protected                                          --
--                                                                                             --
-------------------------------------------------------------------------------------------------

M.Protected = {}

function M.Protected.TryGetProxy(entity, proxy)
    if entity[proxy] ~= nil then
        return entity[proxy]
    else
        error("Not a valid proxy")
    end
end

---@param query string
---@param arity number
---@return table
function M.Protected.TryGetDB(query, arity)
    local success, result = pcall(function()
        local db = Osi[query]
        if db and db.Get then
            return db:Get(table.unpack({}, 1, arity))
        end
    end)

    if success then
        return result
    else
        M.Log.Error("Failed to get DB", query, result)
        return {}
    end
end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                            UUID                                             --
--                                                                                             --
-------------------------------------------------------------------------------------------------

M.UUID = {}

function M.UUID.IsGUID(str)
    local x = "%x"
    local t = { x:rep(8), x:rep(4), x:rep(4), x:rep(4), x:rep(12) }
    local pattern = table.concat(t, "%-")

    return str:match(pattern)
end

function M.UUID.GetGUID(str)
    if str ~= nil and type(str) == "string" then
        return string.sub(str, (string.find(str, "_[^_]*$") ~= nil and (string.find(str, "_[^_]*$") + 1) or 0), nil)
    end
    return ""
end

function M.UUID.Equals(item1, item2)
    if type(item1) == "string" and type(item2) == "string" then
        return (M.UUID.GetGUID(item1) == M.UUID.GetGUID(item2))
    end

    return false
end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                           Logging                                           --
--                                                                                             --
-------------------------------------------------------------------------------------------------

M.Log = {}

function M.Log.Info(...)
    Ext.Utils.Print(Mod.ModPrefix .. " [Info]", ...)
end

function M.Log.Warn(...)
    Ext.Utils.PrintWarning(Mod.ModPrefix .. " [Warning]", ...)
end

function M.Log.Debug(...)
    if Mod.Debug then
        Ext.Utils.Print(Mod.ModPrefix .. " [Debug]", ...)
    end
end

function M.Log.Dump(...)
    for i, v in pairs({ ... }) do
        M.Log.Debug(i .. ":", Ext.DumpExport(v))
    end
end

function M.Log.Error(...)
    Ext.Utils.PrintError(Mod.ModPrefix .. " [Error]", ...)
end

return M
