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

    HasPermission = function (checkAgainst, permission)

        if type(checkAgainst) ~= "table" then return false end

        local hasPermission = false

        if type(permission) == "table" then
            for _, check in pairs(checkAgainst) do
                for _, perm in pairs(permission) do
                    if check == perm then
                        hasPermission = true
                    end
                end
            end
        else
            for _, check in pairs(checkAgainst) do
                if permission == check then
                    hasPermission = true
                end
            end
        end

        return hasPermission
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
