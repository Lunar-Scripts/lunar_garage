-- Resource Metadata
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Lunar Scripts'
description 'Garage system'
version '1.0.0'

-- What to run
escrow_ignore {
    'config.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua'
}
client_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'client/main.lua'
} 
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'locales/*.lua',
    'server/main.lua'
} 
