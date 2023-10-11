fx_version "adamant"
game "gta5"

lua54 'yes'

dependencies {
    'ox_lib'
}

shared_scripts {
    '@ox_lib/init.lua',
}

server_scripts {
   "src/main.lua",
   "example/main.lua"
}

server_only 'yes'