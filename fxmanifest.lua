fx_version 'adamant'
game 'common'

description 'Droopies Ped Spawning'
author 'Droopies'
version '1.0'


client_scripts {
    '@droopies-peds/client/cl_fetching.lua',
    'client/*.lua'
}
server_scripts {
    '@droopies-peds/server/sv_fetching.lua',
    'server/*.lua'
}