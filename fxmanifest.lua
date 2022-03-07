fx_version 'cerulean'
games {'gta5'}
resource_version '1.2.2 By criminalist'
description 'ESX Interceptor'

client_scripts {
   '@es_extended/locale.lua',
   'locales/*.lua',
   'config.lua',
   'client/client.lua'
}

shared_script '@es_extended/imports.lua'

server_scripts {
   "@oxmysql/lib/MySQL.lua",
   '@es_extended/locale.lua',
   'config.lua',
   'locales/*.lua',
   'server/server.lua'
}
