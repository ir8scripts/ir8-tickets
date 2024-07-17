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

    -----------------------------------------------------------
    -- 
    --                    DISCORD WEBHOOK
    -- 
    -----------------------------------------------------------

    SendDiscordEmbed = function (options)

        if not IR8.Config.Discord.WebhookEnabled then return end

        if type(options) ~= "table" then
            return false
        end

        if not options.title then
            return false
        end

        if not options.message then
            return false
        end

        local embed = {
              {
                  ["title"] = "**".. options.title .."**",
                  ["description"] = options.message,
              }
        }

        if options.color then
            embed[1].color = options.color
        end

        if options.footer then
            embed[1].footer = {
                ["text"] = options.footer
            }
        end
      
        PerformHttpRequest(IR8.Config.Discord.WebhookUrl, function(err, text, headers) 
            print(err)
        end, 'POST', json.encode({username = IR8.Config.Discord.AuthorName, embeds = embed}), { ['Content-Type'] = 'application/json' })
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
