------------------------------------------------------------
--                 CORE BRIDGE DETERMINATION
------------------------------------------------------------

IR8.Bridge = {
    Core = nil
}

-- Get the core object based on framework provided
function IR8.Bridge.GetCoreObject()
    if not IR8.Bridge.Core then
        if IR8.Config.Framework == 'esx' then
            IR8.Bridge.Core = exports['es_extended']:getSharedObject()
        elseif IR8.Config.Framework == 'qb' then
            IR8.Bridge.Core = exports['qb-core']:GetCoreObject()
        end
    end
    
    return IR8.Bridge.Core
end

IR8.Bridge.Core = IR8.Config.Framework ~= 'none' and IR8.Bridge.GetCoreObject() or nil

------------------------------------------------------------
--                  CORE BRIDGE FUNCTIONS
------------------------------------------------------------

-- Returns the player name based on framework
function IR8.Bridge.GetPlayerName (src)
    if IR8.Config.Framework == 'esx' and IR8.Bridge.Core then
        local xPlayer = IR8.Bridge.Core.GetPlayerFromId(src)
        if xPlayer == nil then return nil end
        return xPlayer.getName()
    elseif IR8.Config.Framework == 'qb' and IR8.Bridge.Core then
        local Player = IR8.Bridge.Core.Functions.GetPlayer(src)
        return Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    else
        return nil
    end
end

-- Returns the player identifier based on framework
function IR8.Bridge.GetPlayerIdentifier (src)
    if IR8.Config.Framework == 'esx' and IR8.Bridge.Core then
        local xPlayer = IR8.Bridge.Core.GetPlayerFromId(src)
        if xPlayer == nil then return nil end
        return xPlayer.getIdentifier()
    elseif IR8.Config.Framework == 'qb' and IR8.Bridge.Core then
        local Player = IR8.Bridge.Core.Functions.GetPlayer(src)
        return Player.PlayerData.citizenid
    else
        return nil
    end
end

-- Returns the player permission based on framework
-- Returns array of groups player belongs to (Example: ["admin", "mod"])
function IR8.Bridge.GetPlayerPermission (src)
    local groups = {}

    if IR8.Config.Framework == 'esx' and IR8.Bridge.Core then
        local xPlayer = IR8.Bridge.Core.GetPlayerFromId(src)
        if xPlayer == nil then return groups end
        local Group = xPlayer.getGroup()
        table.insert(groups, Group)
    elseif IR8.Config.Framework == 'qb' and IR8.Bridge.Core then
        local permissions = IR8.Bridge.Core.Functions.GetPermission(src)

        for g, hasPerm in pairs(permissions) do
            if hasPerm == true then
                table.insert(groups, g)
            end
        end
    end

    return groups
end

-- Returns player source if they are online
function IR8.Bridge.GetPlayerSourceIfOnlineByIdentifier (identifier)
    local src = nil

    -- Iterate through ESX online players and find the identifier that matches.
    if IR8.Config.Framework == 'esx' and IR8.Bridge.Core then
        local xPlayers = IR8.Bridge.Core.GetPlayers()

        for i=1, #xPlayers, 1 do
            local xPlayer = IR8.Bridge.Core.GetPlayerFromId(xPlayers[i])

            if xPlayer.getIdentifier() == identifier then
                src = xPlayer.source
            end
        end

    -- Find player by citizen id (only returns if online)
    elseif IR8.Config.Framework == 'qb' and IR8.Bridge.Core then
        local Player = IR8.Bridge.Core.Functions.GetPlayerByCitizenId(identifier)
        if Player ~= nil then
            src = Player.PlayerData.source
        end
    end

    return src
end