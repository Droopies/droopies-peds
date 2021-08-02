local Peds = {}

Peds[#Peds + 1] = {
    id = 'testped',
    position = {
        coords = vector3(30.33, -1347.21, 29.5),
        heading = 327.50723266602,
    },
    pedType = 0,
    model = 'a_f_m_fatcult_01',
    networked = false,
    distance = 10.0,
    settings = {
        { mode = 'invincible', active = true },
        { mode = 'ignore', active = true },
        { mode = 'freeze', active = true },
    },
    animation = {testdic = 'timetable@ron@ig_3_couch' , testanim = 'base' }
}

fetching.register('droopies-peds:fetchPeds', function()
    return Peds
end)