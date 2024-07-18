-------------------------------------------------
-- 
-- STATE
-- 
-------------------------------------------------
PlayerData = {}
PlayerLoaded = false

-------------------------------------------------
-- 
-- EVENTS
-- 
-------------------------------------------------

-- Init event on resource start
function init ()
  IR8.Utilities.DebugPrint("[Method] Init invoked")

  -- Check for admin privs
  local admin = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'HasAdminPermissions', false)

  SendNUIMessage({ 
    action = "init", 
    debug = IR8.Config.Debugging,
    admin = admin,
    ticketConfiguration = IR8.Config.TicketConfiguration
  })
end

-- PlayerLoaded event handler based on framework
if IR8.Bridge.Client.EventPlayerLoaded then
  RegisterNetEvent(IR8.Bridge.Client.EventPlayerLoaded)
  AddEventHandler (IR8.Bridge.Client.EventPlayerLoaded, function()
    if not PlayerLoaded then
      init()
    end
  end)
end

-- Show the NUI
RegisterNetEvent(IR8.Config.ClientCallbackPrefix .. "ShowNUI")
AddEventHandler (IR8.Config.ClientCallbackPrefix .. "ShowNUI", function(admin)

  -- Loads the tickets on each show request
  local tickets = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'Tickets_Load', false)
  SendNUIMessage({ action = "tickets", tickets = tickets })

  -- Show UI
  SendNUIMessage({ action = "show", admin = admin, theme = IR8.Config.Theme and IR8.Config.Theme or false })
  SetNuiFocus(true, true)
end)

-------------------------------------------------
-- 
-- NUI EVENTS
-- 
-------------------------------------------------

-- Hide NUI
RegisterNUICallback('hide', function(_, cb)
  SendNUIMessage({ action = "hide"  })
  SetNuiFocus(false, false)
  cb({})
end)

-- Retrieve ticket information and send back
RegisterNUICallback('ticket', function(data, cb)

  -- Get ticket information
  local res = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'Ticket_Load', false, data)

  -- Send response
  cb(res)
end)

-- Retrieve ticket information and send back
RegisterNUICallback('status', function(data, cb)

  -- Update status
  local res = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'Ticket_UpdateStatus', false, data)

  if res.success then
    local tickets = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'Tickets_Load', false)
    SendNUIMessage({ action = "tickets", tickets = tickets })
  end

  -- Send response
  cb({ success = true })
end)

-- Retrieve list of tickets and send back
RegisterNUICallback('tickets', function(_, cb)

  -- Get list of tickets
  local tickets = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'Tickets_Load', false)
  SendNUIMessage({ action = "tickets", tickets = tickets })

  -- Send response
  cb({ success = true })
end)

-- Ticket reply creation
RegisterNUICallback('reply', function(data, cb)
  local res = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'Ticket_CreateReply', false, data)
  cb(res)
end)

-- Ticket creation
RegisterNUICallback('create', function(data, cb)

  -- If position is included
  if data.position then
    local playerCoords = GetEntityCoords(PlayerPedId())
    data.position = json.encode({
      x = playerCoords.x,
      y = playerCoords.y,
      z = playerCoords.z
    })
  end

  local res = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'Ticket_Create', false, data)

  if res.success then
    local tickets = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'Tickets_Load', false)
    SendNUIMessage({ action = "tickets", tickets = tickets })
  end

  cb(res)
end)

-- Teleport request
RegisterNUICallback('teleport', function(data, cb)
  SetEntityCoords(PlayerPedId(), data.x, data.y, data.z)
  cb({ })
end)

-------------------------------------------------
-- 
-- ON RESOURCE START
-- 
-------------------------------------------------
AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    if not PlayerLoaded then
      PlayerLoaded = true
      init()
    end
  end
end)

-------------------------------------------------
-- 
-- CLEANUP ON RESOURCE STOP
-- 
-------------------------------------------------
AddEventHandler('onResourceStop', function(resource)
  if resource == GetCurrentResourceName() then
    -- Any cleanup if necessary.If not, remove this
  end
end)