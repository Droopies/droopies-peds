handler = PedHandlers:new()

Citizen.CreateThread(function()
    handler:startThread(500)
end)

function GetNPC(id)
    if not handler:npcExists(id) then return end
    return handler.peds[id]['npc']
end

exports('GetNPC', GetNPC)

function RegisterNPC(data)
    if not handler:npcExists(data.id) then
        local npc = Ped:new(data.id, data.pedType, data.model, data.position, (type(data.appearance) == 'string' and json.decode(data.appearance) or data.appearance), data.animation, data.networked, data.settings, data.flags, data.scenario, data.blip)

        handler:addNPC(npc, data.distance)

        return npc
    else
        handler.peds[data.id]['npc']['position'] = data.position

        return handler.peds[data.id]['npc']
    end
end

exports('RegisterNPC', RegisterNPC)

function RemoveNPC(id)
    if not handler:npcExists(id) then return end
    handler:removeNPC(id)
end

exports('RemoveNPC', RemoveNPC)

function DisableNPC(id)
    if not handler:npcExists(id) then return end
    handler:disableNPC(id)
end

exports('DisableNPC', DisableNPC)

function EnableNPC(id)
    if not handler:npcExists(id) then return end
    handler:enableNPC(id)
end

exports('EnableNPC', EnableNPC)

function UpdateNPCData(id, key, value)
    if not handler:npcExists(id) then return end
    handler.peds[id]['npc'][key] = value
end

exports('UpdateNPCData', UpdateNPCData)

function FindNPCByHash(hash)
    local found, npc = false

    for _, data in pairs(handler.peds) do
        if GetHashKey(data.npc.id) == hash then
            found, npc = true, data.npc
            break
        end
    end

    return found, npc
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    for _, data in pairs(handler.peds) do
        data['peds']:delete()
    end
end)
