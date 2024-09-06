-- Attaches to the IR8 table 
-- Example call : IR8.Utilities.DebugPrint('foo-bar')
IR8.Utilities = {

    ---------------------------------------------------------
    -- 
    -- DEBUGGING
    --
    ---------------------------------------------------------

    DebugPrint = function(...)
        if not IR8.Config.Debugging then
            return
        end

        local args<const> = {...}

        local appendStr = ''
        for _, v in ipairs(args) do
            appendStr = appendStr .. ' ' .. tostring(v)
        end

        print(appendStr)
    end,

    ---------------------------------------------------------
    -- 
    -- Permission Check
    --
    ---------------------------------------------------------

    HasPermission = function (src)
        if not src or src == '' then return false end
        local permissions = IR8.Config.AdminPermissions
        if not permissions then return false end

        if type(permissions) ~= "table" then
            return IsPlayerAceAllowed(src, permissions)
        end

        for _, permission in pairs(permissions) do
            if IsPlayerAceAllowed(src, permission) then
                return true
            end
        end

        return false
    end,

    ---------------------------------------------------------
    -- 
    -- NOTIFICATIONS
    --
    ---------------------------------------------------------
    
    -- Server side notification
    NotifyFromServer = function (source, id, title, message, type)
        TriggerClientEvent('ox_lib:notify', source, {
            id = id,
            title = title,
            description = message,
            type = type
        })
    end,

    -- Client side notification
    Notify = function (id, title, message, type)
        lib.notify({
            id = id,
            title = title,
            description = message,
            type = type
        })
    end,
}
