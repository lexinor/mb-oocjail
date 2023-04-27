lib.locale()
local globalJailTime = 0

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
    local bannedPlayer = ESX.GetPlayerFromId(id)
    local bannedCitizenId = bannedPlayer.identifier
    local bannedCharInfo = bannedPlayer

    --Admin info
    local adminIdentifierlist = ExtractIdentifiers(adminID)
    local adminDiscord = "<@"..adminIdentifierlist.discord:gsub("discord:", "")..">"
    local adminPlayer = ESX.GetPlayerFromId(adminID)
    local adminCharInfo = adminPlayer

    local embed = {
            {
                ["color"] = color, --Set color
                ["author"] = {
                    ["icon_url"] = Config.Log.avatar, -- et avatar
                    ["name"] = Config.Log.server_name, --Set name
                },
                ["title"] = "**".. title .."**", --Set title
                ["description"] = locale("log.jail_additional", {discord = discord, ID = id, fName = bannedCharInfo.firstName, lName = bannedCharInfo.lastName, CID = bannedCitizenId, adDiscord = adminDiscord, adFName = adminCharInfo.firstName, adLName = adminCharInfo.lastName, message = message}), --Set message
                ["footer"] = {
                    ["text"] = '' ..time.year.. '/' ..time.month..'/'..time.day..' '.. time.hour.. ':'..time.min, --Get time
                },
            }
        }

    PerformHttpRequest(Config.Log.webhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

ESX.RegisterCommand(Config.JailCommandName.name, Config.JailCommandName.permission, function(xPlayer, args, showError)
    
    if not args.id or not args.time or not args.reason then
        print(json.encode(args))
        MBNotify(locale("notify.title"), locale("error.fill_argument"), 'error', source)
    else
        print(json.encode(args))
        local src = xPlayer.source
        local reason = {}
        for i = 3, #args, 1 do
            reason[#reason+1] = args[i]
        end

        if src then
            TriggerEvent("mb-oocjail:server:JailPlayer", tonumber(args.id ), tonumber(args.time))
            MBNotify(locale("notify.title"), locale("success.you_have_been_jailed"), 'error', src)
            sendToDiscord(locale("log.jail_title"), locale("log.jail_description", tonumber(args.time), table.concat(reason, " ")), Config.Log.jail_color, tonumber(args.id), src)
        else
            MBNotify(locale("notify.title"), locale("error.no_permission"), 'error', src)
        end
    end
end, false, {help = Config.JailCommandName.help, arguments = {
    {name = locale("argument.id"), help = locale("argument.id_help"), type = "number"}, 
    {name = locale("argument.time"), help = locale("argument.time_help"), type = "number"}, 
    {name = locale("argument.reason"), help = locale("argument.reason_help"), type = "string"}
}})

ESX.RegisterCommand(Config.UnjailCommandName.name, Config.UnjailCommandName.permission, function(xPlayer, args, showError)
    if xPlayer then
        local playerId = tonumber(args.id)
        TriggerClientEvent("mb-oocjail:client:UnJailOOC", playerId)
    else
        MBNotify(locale("notify.title"), locale("error.no_permission"), 'error', xPlayer.source)
    end
end, false, {help = Config.UnjailCommandName.help, arguments = {{name = locale("argument.id"), help = locale("argument.id_help"), type = "number"}}})

ESX.RegisterCommand(Config.CheckTimeLeftCommand.name, Config.CheckTimeLeftCommand.permission, function(xPlayer, args, showError)
    local src = source

    if Config.CheckTimeLeftCommand.allow then
        if xPlayer.getMeta("oocjail") > 0 then
            if Config.CheckJailTimeType == "notify" then
                MBNotify(locale("notify.title"), locale("notify.check_time", {time = globalJailTime}), 'info', src)
            elseif Config.CheckJailTimeType == "chat" then
                TriggerClientEvent('chat:addMessage', src, {
                    template = '<div class="chat-message"><div class="chat-message"><font color="#D994DB"><strong>'..locale("notify.check_time", {time = globalJailTime})..'</div></div>',
                })
            else
                print("Your choice of output time check is invalid, we dont support that type of output yet! Check your config please.")
            end
        else
            MBNotify(locale("notify.title"), locale("error.no_permission"), 'error', src)
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
    local Player = ESX.GetPlayerFromId(src)
    local OtherPlayer = ESX.GetPlayerFromId(playerId)

    OtherPlayer.setMeta("oocjail", time)

    TriggerClientEvent("mb-oocjail:client:AdminJail", OtherPlayer.source, time)
end)

RegisterNetEvent('mb-oocjail:server:SetJailTime', function(jailTime)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    if not Player then return end
    Player.setMeta("oocjail", jailTime)

    if jailTime ~= 0 then
        TriggerClientEvent('chat:addMessage', src, {
            template = '<div class="chat-message"><div class="chat-message"><font color="#D994DB"><strong>'..locale("notify.jailed_player", {time = jailTime})..'</div></div>',
        })
    else
        TriggerClientEvent('chat:addMessage', src, {
            template = '<div class="chat-message"><div class="chat-message"><font color="#D994DB"><strong>'..locale("notify.released_player")..'</div></div>',
        })
    end

    if jailTime > 0 and Config.LostJob then
        if Player.job.name ~= "unemployed" then
            Player.setJob("unemployed")
            MBNotify(locale("notify.title"), locale("success.you_lost_job"), 'info', src)
        end
    end
end)

RegisterNetEvent("mb-oocjail:server:ClearInv", function()
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    if not Player then return end
    if Config.DeleteInventory then
        Wait(2000)
        Player.Functions.ClearInventory()
        MBNotify(locale("notify.title"), locale("success.clear_inv"), 'info', src)
    end
end)