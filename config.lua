Config = {}

--Where should the player been jailed?
--Config.JailLocation = vector3(1735.56, 2575.88, 45.56)
Config.JailLocation = vector3( 994.5925, -3002.594, -39.64699)

--Where should the player been released?
Config.OutJailLocation = vector3(1847.84, 2585.95, 45.67)

--Will they lose their current job?
Config.LostJob = true

--Will their inventory be wipe out? (No way to get the item back, so be careful when set true)
Config.DeleteInventory = false

--What kind of notify you want to use? (options: "qb-core", "okokNotify", "roda-notify")
--You can easily edit all the notifications in the shared/shared.lua
Config.Notify = "ox"

--Should the script prevent player from escaping? They will be pull back everytime they going to far
Config.PreventEscapeMod = {
    --Set true if you want this feature to run. (false otherwise)
    on = true,
    --How far is the player allowed to go before being pulled back?
    distance = 15,
    --How often should the script check player coords? (in ms)
    checkTime = 1500,
}

--Log/Annoucement on Discord
Config.Log = {
    --Leave the webhook blank ("") if you dont want this feature
    webhook = "",
    --Set avatar for the log/annoucement (optional)
    avatar = "https://media.discordapp.net/attachments/1037224938005872661/1037225027453599744/Guess_project.png",
    --Set the server name for the log/annoucement (optional)
    server_name = "New Dawn RP",
    --Color for the log/annoucement (optional)
    jail_color = 16711680,
}

--Config for jail command
Config.JailCommandName = {
    --Who can use this command? (options: 'god', 'admin')
    permission = {"superadmin", "admin"},
    --What should the command name be? (/oocjail)
    name = "jail",
    --Help message for the command
    help = "Met un joueur en prison admin"
}

--Config for unjail command
Config.UnjailCommandName = {
    --Who can use this command? (options: 'god', 'admin')
    permission = {"superadmin", "admin"},
    --What should the command name be? (/oocunjail)
    name = "unjail",
    --Help message for the command
    help = "Libère un joueur de la prison admin"
}

--Check time command for player
--How do you want the check displayed? (options: 'chat', 'notify')
Config.CheckJailTimeType = "notify"
Config.CheckTimeLeftCommand = {
    --Do you want to allow players to use this command?
    allow = true,
    --What should the command name be? (/ooctimecheck)
    name = "timecheck",
    --Help message for the command
    help = "Connaitre le temps restant avant libération",
    --Who can use this command? (options: 'god', 'admin')
    permission = {"user"},
}