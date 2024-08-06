---@class Mod
local M = {}

M.ModUUID = ""
M.ModPrefix = ""
M.ModTableKey = ""
M.ModVersion = { major = 0, minor = 0, revision = 0 }
M.Debug = true

M.PersistentVarsTemplate = {}

function M.PreparePersistentVars()
    -- maybe later
    -- Ext.Vars.RegisterModVariable(M.ModUUID, "PersistentVars", {
    --     Server = true,
    --     Client = true,
    --     SyncToClient = true,
    -- })
    -- Ext.Vars.SyncModVariables(M.ModUUID)
    --
    -- local vars = Ext.Vars.GetModVariables(M.ModUUID)
    --
    -- if not vars["PersistentVars"] then
    --     vars["PersistentVars"] = {}
    -- end
    -- PersistentVars = vars["PersistentVars"]

    if not PersistentVars then
        PersistentVars = {}
    end

    -- Remove keys we no longer use in the Template
    for k, _ in ipairs(PersistentVars) do
        if M.PersistentVarsTemplate[k] == nil then
            PersistentVars[k] = nil
        end
    end

    -- Add new keys to the PersistentVars recursively
    local function applyTemplate(vars, template)
        for k, v in pairs(template) do
            if type(v) == "table" then
                if vars[k] == nil then
                    vars[k] = {}
                end

                vars[k] = applyTemplate(vars[k], v)
            else
                if vars[k] == nil then
                    vars[k] = v
                end
            end
        end
        return vars
    end
    PersistentVars = applyTemplate(PersistentVars, M.PersistentVarsTemplate)
end

return M
