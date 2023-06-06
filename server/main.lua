lib.locale()
local globalJailTime = 0

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer, isNew)
    if xPlayer.metadata["oocjail"] and xPlayer.metadata["oocjail"] > 0 then
        TriggerEvent("mb-oocjail:server:JailPlayer", tonumber(playerId), tonumber(xPlayer.metadata["oocjail"]))
        SetPlayerRoutingBucket(playerId, playerId)
	end
end)

function ExtractIdentifiers(id)
	local identifiers = {
		steam = "",
		ip = "",
		discord = "",
		license = "",
		xbl = "",
		live = ""
	}

	for i = 0, GetNumPlayerIdentifiers(id) - 1 do
		local playerID = GetPlayerIdentifier(id, i)

		if string.find(playerID, "steam") then
			identifiers.steam = playerID
		elseif string.find(playerID, "ip") then
			identifiers.ip = playerID
		elseif string.find(playerID, "discord") then
			identifiers.discord = playerID
		elseif string.find(playerID, "license") then
			identifiers.license = playerID
		elseif string.find(playerID, "xbl") then
			identifiers.xbl = playerID
		elseif string.find(playerID, "live") then
			identifiers.live = playerID
		end
	end

	return identifiers
end

function sendToDiscord(title, message, color, id, adminID) --Functions to send the log to discord
    local time = os.date("*t")

    --Banned player info
    local identifierlist = ExtractIdentifiers(id)
	local discord = "<@"..identifierlist.discord:gsub("discord:", "")..">"
    local jailedPlayer = ESX.GetPlayerFromId(id)
    local jailedIdentifier = jailedPlayer.identifier

    --Admin info
    local adminIdentifierlist = ExtractIdentifiers(adminID)
    local adminDiscord = "<@"..adminIdentifierlist.discord:gsub("discord:", "")..">"
    local adminPlayer = ESX.GetPlayerFromId(adminID)
    
    local embed = {
            {
                ["color"] = color, --Set color
                ["author"] = {
                    ["icon_url"] = Config.Log.avatar, -- et avatar
                    ["name"] = Config.Log.server_name, --Set name
                },
                ["title"] = "**".. title .."**", --Set title
                ["description"] = locale("log.jail_additional", discord, id, jailedPlayer.get("firstName"), jailedPlayer.get("lastName"), jailedIdentifier, adminDiscord, adminPlayer.get("firstName"), adminPlayer.get("lastName"), message), --Set message
                ["footer"] = {
                    ["text"] = '' ..time.day.. '/' ..time.month..'/'..time.year..' à '.. time.hour.. ':'..time.min, --Get time
                },
            }
        }

    PerformHttpRequest(Config.Log.webhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

ESX.RegisterCommand(Config.JailCommandName.name, Config.JailCommandName.permission, function(xPlayer, args, showError)
    
    if not args.id or not args.time or not args.reason then
        MBNotify(locale("notify.title"), locale("error.fill_argument"), 'error', source)
    else
        local targetPlayer = nil
        if args.id == "me" then
            targetPlayer = xPlayer
            playerId = xPlayer.source
        else
            targetPlayer = ESX.GetPlayerFromId(args.id)
            playerId = args.id
        end
        if targetPlayer then
            TriggerEvent("mb-oocjail:server:JailPlayer", tonumber(args.id), tonumber(args.time))
            MBNotify(locale("notify.title"), locale("success.you_have_been_jailed"), 'error', targetPlayer.source)
            sendToDiscord(locale("log.jail_title"), locale("log.jail_description", tonumber(args.time), args.reason), Config.Log.jail_color, tonumber(args.id), targetPlayer.source)
        else
            MBNotify(locale("notify.title"), locale("error.no_playerfound"), 'error', xPlayer.source)
        end
    end
end, false, {help = Config.JailCommandName.help, arguments = {
    {name = locale("argument.id"), help = locale("argument.id_help"), type = "number"},
    {name = locale("argument.time"), help = locale("argument.time_help"), type = "number"}, 
    {name = locale("argument.reason"), help = locale("argument.reason_help"), type = "string"},
}})

ESX.RegisterCommand(Config.UnjailCommandName.name, Config.UnjailCommandName.permission, function(xPlayer, args, showError)
    if xPlayer then
        local playerId = nil
        if args.id == "me" then
            playerId = xPlayer.source
        else
            playerId = args.id
        end
        TriggerClientEvent("mb-oocjail:client:UnJailOOC", playerId)
    else
        MBNotify(locale("notify.title"), locale("error.no_permission"), 'error', xPlayer.source)
    end
end, false, {help = Config.UnjailCommandName.help, arguments = {{name = locale("argument.id"), help = locale("argument.id_help"), type = "number"}}})

ESX.RegisterCommand(Config.CheckTimeLeftCommand.name, Config.CheckTimeLeftCommand.permission, function(xPlayer, args, showError)
    local src = xPlayer.source

    if Config.CheckTimeLeftCommand.allow then
        if xPlayer.getMeta("oocjail") > 0 then
            if Config.CheckJailTimeType == "notify" then
                MBNotify(locale("notify.title"), locale("notify.check_time", globalJailTime), 'inform', src)
            elseif Config.CheckJailTimeType == "chat" then
                MBNotify(locale("notify.title"), locale("notify.check_time", globalJailTime), "inform", src)
            else
                print("Your choice of output time check is invalid, we dont support that type of output yet! Check your config please.")
            end
        else
            MBNotify(locale("notify.title"), locale("error.no_playerfound"), 'error', src)
        end
    else
        MBNotify(locale("notify.title"), locale("error.no_permission"), 'error', src)
    end
end, false, {help = Config.CheckTimeLeftCommand.help })

RegisterNetEvent("mb-oocjail:server:CheckJailTime", function(jailTime)
    globalJailTime = jailTime
end)

RegisterNetEvent("mb-oocjail:server:JailPlayer", function(playerId, time)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local OtherPlayer = ESX.GetPlayerFromId(playerId)
    if OtherPlayer then
        OtherPlayer.setMeta("oocjail", time)
        SetPlayerRoutingBucket(OtherPlayer.source, OtherPlayer.source)
        TriggerClientEvent("mb-oocjail:client:AdminJail", OtherPlayer.source, time)
    end    
end)

RegisterNetEvent('mb-oocjail:server:SetJailTime', function(jailTime)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    xPlayer.setMeta("oocjail", jailTime)

    if jailTime ~= 0 then
        MBNotify("Temps d'emprisonement", locale("notify.jailed_player", jailTime), "error", src)
    else
        MBNotify("Temps d'emprisonement", locale("notify.released_player"), "inform", src)
        SetPlayerRoutingBucket(src, 0)
        local jobBeforeJail = xPlayer.getMeta('jobBeforeJail')
        xPlayer.setJob(jobBeforeJail.jobName, jobBeforeJail.grade)
    end

    if jailTime > 0 and Config.LostJob then
        if xPlayer.job.name ~= "unemployed" then
            xPlayer.setMeta("jobBeforeJail", { jobName = xPlayer.job.name, grade = xPlayer.job.grade })
            xPlayer.setJob("unemployed", 0)
            MBNotify(locale("notify.title"), locale("success.you_lost_job"), 'inform', src)
        end
    end
end)

RegisterNetEvent("mb-oocjail:server:ClearInv", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if Config.DeleteInventory then
        Wait(2000)
        xPlayer.Functions.ClearInventory()
        MBNotify(locale("notify.title"), locale("success.clear_inv"), 'inform', src)
    end
end)


RegisterNetEvent('mb-oocjail:server:UnJailOOC', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    SetPlayerRoutingBucket(xPlayer.source, 0)
    local jobBeforeJail = xPlayer.getMeta('jobBeforeJail')
    xPlayer.setJob(jobBeforeJail.jobName, jobBeforeJail.grade)
    TriggerClientEvent("mb-oocjail:client:UnJailOOC", xPlayer.source)
end)