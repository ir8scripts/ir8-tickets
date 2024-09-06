-------------------------------------------------
-- 
-- LOGGIN CONFIGURATION
-- Thanks to complex from Project Sloth for the 
-- suggestion to move this config to here.
-- 
-- Thanks to simsonas86 for fivemerr support
--
-------------------------------------------------

-- Send discord notifications when tickets are created / updated
Logging = {

    -- Only sends webhooks if this isn't empty
    LoggingService = 'discord', -- 'discord' | 'fivemerr' (discord is not recommended as it is not a logging service, fivemerr is a free alternative)

    -- Discord webhook url or Fivemerr API token
    LoggingTarget = 'url',

    -- The author name of the webhook
    AuthorName = 'IR8 Ticket Manager'
}

-------------------------------------------------
-- 
-- COMMANDS
-- 
-------------------------------------------------
lib.addCommand(IR8.Config.Commands.Tickets, {
    help = IR8.Config.Commands.TicketsDescription,
    params = {}
}, function(source, args, raw)
    local hasAdminPermission = IR8.Utilities.HasPermission(source)
    TriggerClientEvent(IR8.Config.ClientCallbackPrefix .. "ShowNUI", source, hasAdminPermission)
end)

-------------------------------------------------
-- 
-- NOTIFICATIONS
-- 
-------------------------------------------------
function SendNotificationIfOnline (identifier, title, notification, type)
    local src = IR8.Bridge.Server.GetPlayerSourceIfOnlineByIdentifier(identifier)

    if src then
        IR8.Utilities.NotifyFromServer(src, "ticket_manager", title, notification, type)
    end
end


-------------------------------------------------
-- 
-- CALL BACKS
-- 
-------------------------------------------------

-- Return admin privs (bool)
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "HasAdminPermissions", function (src)
    return IR8.Utilities.HasPermission(src)
end)

-- Load all tickets
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "Tickets_Load", function (src)
    IR8.Utilities.DebugPrint('[EVENT] ' .. IR8.Bridge.Server.GetPlayerIdentifier(src) .. ' loaded ticket list data.')

    -- Check if user has permissions and get their identifier
    local hasAdminPermission = IR8.Utilities.HasPermission(src)
    local identifier = IR8.Bridge.Server.GetPlayerIdentifier(src)

    -- Pull tickets based on privelage
    return IR8.Database.GetTickets(hasAdminPermission, identifier)
end)

-- Load ticket data
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "Ticket_Load", function (src, data)
    IR8.Utilities.DebugPrint('[EVENT] ' .. IR8.Bridge.Server.GetPlayerIdentifier(src) .. ' loaded ticket data for ticket id: ' .. data.id .. '.')

    -- Get ticket data from database
    return IR8.Database.GetTicket(data.id)
end)

-- Update ticket status
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "Ticket_UpdateStatus", function (src, data)
    IR8.Utilities.DebugPrint('[EVENT] ' .. IR8.Bridge.Server.GetPlayerIdentifier(src) .. ' updated ticket status for id: ' .. data.id .. ' to ' .. data.status)

    local name = IR8.Bridge.Server.GetPlayerName(src)
    local res = IR8.Database.UpdateTicketStatus(data.id, data.status)

    if res.success then
        local ticketData = IR8.Database.GetTicket(data.id)
        if ticketData then
            SendNotificationIfOnline(ticketData.identifier, "Ticket Status", "Your ticket status has been updated to " .. data.status .. ".")
        end

        -- Send discord webhook
        IR8.Utilities.DebugPrint("Sending discord notification for created ticket.")
        SendLog({
            title = "Ticket Status Update",
            message = "A ticket status was updated to " .. data.status .. " by " .. name .. " for Ticket #" .. data.id .. " - " .. ticketData.title,
            source = src
        })
    end

    -- Get ticket data from database
    return res
end)

-- For creating a ticket
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "Ticket_CreateReply", function (src, data)
    local identifier = IR8.Bridge.Server.GetPlayerIdentifier(src)
    local name = IR8.Bridge.Server.GetPlayerName(src)
    local res = IR8.Database.CreateReply(identifier, name, data)

    if res.success then 
        local ticketData = IR8.Database.GetTicket(data.ticket_id)
        if ticketData then
            SendNotificationIfOnline(ticketData.identifier, "Ticket Reply", "You have received a reply on a ticket you created.")
        end

        -- Send discord webhook
        IR8.Utilities.DebugPrint("Sending discord notification for created ticket.")
        SendLog({
            title = "New Ticket Reply",
            message = "A ticket was replied to by " .. name .. " for Ticket #" .. data.ticket_id .. " - " .. ticketData.title,
            source = src
        })
    end

    return res
end)

-- For creating a ticket
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "Ticket_Create", function (src, data)
    local identifier = IR8.Bridge.Server.GetPlayerIdentifier(src)
    local name = IR8.Bridge.Server.GetPlayerName(src)
    local res = IR8.Database.CreateTicket(identifier, name, data)

    if res.success then 

        -- Send discord webhook
        IR8.Utilities.DebugPrint("Sending discord notification for created ticket.")
        SendLog({
            title = "Ticket Created",
            message = "A ticket was created with title: " .. data.title .. " by " .. name,
            source = src
        })
    end

    return res
end)

-----------------------------------------------------------
--
--                    DISCORD WEBHOOK
--
-----------------------------------------------------------

function SendDiscordEmbed (options)

    if Logging.LoggingTarget == "url" then
        lib.print.error('Attempted to create a log with discord, but webhook url is not defined!')
        return
    end

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

    PerformHttpRequest(Logging.LoggingTarget, function(err, text, headers)
        print(err)
    end, 'POST', json.encode({username = Logging.AuthorName, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function SentFivemerrLog(options)

    if Logging.LoggingTarget == "url" then
        lib.print.error('Attempted to create a log with fivemerr, but API token is not defined!')
        return
    end

    local data = {
        ["level"] = "info",
        ["message"] = options.title,
        ["resource"] = tostring(GetCurrentResourceName()),
        ["metadata"] = {
            ["server-id"] = tostring(options.source),
            ["message"] = options.message
        }
    }

    PerformHttpRequest('https://api.fivemerr.com/v1/logs', function(err, text, headers)
        print(err)
    end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json', ['Authorization'] = tostring(Logging.LoggingTarget) })
end

function SendLog(options)
    if Logging.LoggingService == 'discord' then
        SendDiscordEmbed(options)
    elseif Logging.LoggingService == 'fivemerr' then
        SentFivemerrLog(options)
    else
        return
    end
end