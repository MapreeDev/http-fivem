fx_version "adamant"
game "gta5"

author "Mapree Dev"
version "0.0.1"

lua54 'yes'

dependencies {
    'ox_lib',
    '/native:0xE27C97A0',
}

server_scripts {
    "@vrp/lib/utils.lua",
    '@ox_lib/init.lua',
    "src/main.lua",
    "example/main.lua",
}

server_only 'yes'