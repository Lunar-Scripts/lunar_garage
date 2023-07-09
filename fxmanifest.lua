-- Resource Metadata
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Lunar Scripts'
description 'Garage system'
version '1.0.0'

files {
    'locales/*.json'
}

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'client/cl_edit.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/sv_config.lua',
    'locales/*.lua',
    'server/main.lua'
} 
