local FrameworkObject = nil

-- Load the configuration
local Config = Config or {}

-- Initialize the selected framework
if Config.Framework == "qbcore" then
    FrameworkObject = exports['qb-core']:GetCoreObject()
elseif Config.Framework == "esx" then
    FrameworkObject = exports['es_extended']:getSharedObject()
elseif Config.Framework == "ox" then
    FrameworkObject = exports['ox_core']:GetCoreObject()
else
    print("Invalid framework selected in config.")
    return
end

-- Register the wipe command
if Config.Framework == "qbcore" then
    FrameworkObject.Commands.Add(Config.CleanCommand, Config.CleanCommandInfo, {}, false, function(source, args)
        if source ~= 0 then
            local player = FrameworkObject.Functions.GetPlayer(source)
            if player then
                TriggerClientEvent('QBCore:Notify', source, "This command is restricted to the server console.", 'error')
            end
            return
        end
        ExecuteDataWipe()
    end)
elseif Config.Framework == "esx" then
    RegisterCommand(Config.CleanCommand, function(source, args)
        if source ~= 0 then
            local player = FrameworkObject.GetPlayerFromId(source)
            if player then
                TriggerClientEvent('esx:showNotification', source, "This command can only be executed from the server console.")
            end
            return
        end
        ExecuteDataWipe()
    end, false)
elseif Config.Framework == "ox" then
    FrameworkObject.Commands.Add(Config.CleanCommand, Config.CleanCommandInfo, {}, false, function(source, args)
        if source ~= 0 then
            local player = FrameworkObject.Functions.GetPlayer(source)
            if player then
                TriggerClientEvent('ox:notify', source, "This command is restricted to the server console.")
            end
            return
        end
        ExecuteDataWipe()
    end)
else
    print("Framework not supported in config.")
    return
end

-- Main wipe logic
function ExecuteDataWipe()
    local totalDeleted = 0
    local details = ""

    local dbLibrary = exports[Config.DatabaseLibrary]
    if not dbLibrary then
        print("Invalid database library specified in config.")
        return
    end

    local processedTables = 0
    local totalTables = #Config.TablesToWipe

    for _, tableName in ipairs(Config.TablesToWipe) do
        local query = string.format("DELETE FROM `%s`", tableName)

        dbLibrary:execute(query, {}, function(affectedRows)
            if affectedRows and affectedRows > 0 then
                totalDeleted = totalDeleted + affectedRows
                details = details .. string.format("Table `%s`: %d rows deleted\n", tableName, affectedRows)
            end

            processedTables = processedTables + 1
            if processedTables == totalTables then
                NotifyAdmins(totalDeleted, details)
                ClearAllPlayers()
            end
        end)
    end
end

-- Notify admins through Discord webhook
function NotifyAdmins(totalDeleted, details)
    local webhookMessage = string.format(Config.WebhookMessageTemplate, totalDeleted, details)

    PerformHttpRequest(Config.WebhookURL, function(statusCode)
        if statusCode == 200 then
            print("Wipe notification sent successfully.")
        else
            print("Failed to send webhook notification.")
        end
    end, 'POST', json.encode({
        username = Config.WebhookUsername,
        avatar_url = Config.WebhookAvatar,
        content = webhookMessage,
        embeds = {}
    }), { ['Content-Type'] = 'application/json' })
end

-- Remove all players from the server and shut it down
function ClearAllPlayers()
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        DropPlayer(playerId, Config.KickMessage)
    end
    SetTimeout(5000, function()
        os.exit()
    end)
end
