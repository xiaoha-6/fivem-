fx_version 'cerulean'
game 'gta5'

author 'Kallock - The Goodlife RP Server'
version '1.0.0'
lua54 'yes'

escrow_ignore {
    'client.lua',
    'server.lua',
    'shared.lua',
    'locales/en.lua',
    'sd-menu.lua'
}

client_script {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
	'client.lua',
	'@es_extended/locale.lua',
	'locales/en.lua',
    'sd-menu.lua'
}


server_script 'server.lua'

shared_script {
    'shared.lua',
}

dependency '/assetpacks'