local Peds = {}

Peds[#Peds + 1] = {
    id = 'taxiNPC',
    position = {
        coords = vector3(908.28, -152.24, 73.16),
        heading = 148.24,
    },
    pedType = 7,
    model = 's_m_m_gentransport',
    networked = false,
    distance = 30.0,
    settings = {
        { mode = 'invincible', active = true },
        { mode = 'ignore', active = true },
        { mode = 'freeze', active = true },
    },
    qtarget = {
        distance = 4.5,
        options = {
            {
                event = "ncrp_taxi:clockin",
                label = "Clock In/Out",
                icon = "fas fa-clock"
            },
            {
                event = "ncrp_taxi:getTaxi",
                label = "Take out Taxi",
                icon = "fas fa-taxi"
            },
            {
                event = "ncrp_taxi:putTaxi",
                label = "Return Taxi",
                icon = "fas fa-history"
            },
        }
    },
    --animation = {testdic = 'timetable@ron@ig_3_couch' , testanim = 'base' }
    scenario = "PROP_HUMAN_PARKING_METER"
}

fetching.register('droopies-peds:fetchPeds', function()
    return Peds
end)