Citizen.CreateThread(function()
    local peds = fetching.execute('droopies-peds:fetchPeds')

    for k, v in pairs(peds) do
        exports['droopies-peds']:RegisterNPC(v)
    end
end)