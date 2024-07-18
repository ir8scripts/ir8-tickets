fx_version 'cerulean'
game 'gta5'
author 'IR8 Scripts'
description 'Ticket Manager'
version '1.0.3'
lua54 'yes'

client_script 'client/main.lua'

server_script {
    '@oxmysql/lib/MySQL.lua', 
    'server/main.lua'
}

shared_script { 
    "@ox_lib/init.lua",
    "shared/config.lua",
    "shared/core.lua",
    "shared/utilities.lua",
    "shared/database.lua"
}

ui_page {
    'nui/index.html',
}

files {
	'nui/index.html',
	'nui/js/script.js', 
	'nui/css/style.css'
}