fx_version 'cerulean'

version '1.0.0'

game 'gta5'
description 'Admin Jail'

lua54 'yes'

client_script 'client/main.lua'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config.lua',
	'server/main.lua'
}

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
    'config.lua',
    'shared/shared.lua',
}

files {
    "locales/*.json"
}