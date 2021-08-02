PedHandlers = {}

function PedHandlers:new()
    local this = {}

    this.id = {}
    this.peds = {}
    this.active = false

    self.__index = self
    return setmetatable(this, self)
end

function PedHandlers:npcExists(id)
    return self.peds[id] ~= nil
end

function PedHandlers:getNPCByID(id)
    if self:npcExists(id) then
        return self.peds[id]['peds']
    end
end

function PedHandlers:getNPCByHash(hash)
    for _, data in pairs(self.peds) do
        if GetHashKey(data.npc.id) == hash then
            return data
        end
    end
end

function PedHandlers:addNPC(npc, distance)
    if not npc or not npc.id or self:npcExists(npc.id) then return end

    self.peds[npc.id] = {npc = npc, distance = distance}
end

function PedHandlers:removeNPC(id)
    if not self:npcExists(id) then return end

    self.peds[id]['peds']:delete()

    if self.peds[id]['peds'].blipHandler then
        self.peds[id]['peds'].blipHandler:delete()
    end

    self.peds[id] = nil
end

function PedHandlers:disableNPC(id)
    if not self:npcExists(id) then return end

    if self.peds[id]['peds'].blipHandler then
        self.peds[id]['peds'].blipHandler:delete()
    end

    self.peds[id]['peds']:disable()
end

function PedHandlers:enableNPC(id)
    if not self:npcExists(id) then return end
    self.peds[id]['peds']:enable()
    local currentNPC = self.peds[id]['peds']

    if currentNPC and currentNPC.blip then
        local blipHandler = Blip:new(currentNPC.position.coords, currentNPC.blip)
        blipHandler:add()
        currentNPC.blipHandler = blipHandler
    end
end

function PedHandlers:startThread(delay)
    Citizen.CreateThread(function()
        local idle = delay or 500

        self.active = true

        while self.active do
            local playerCoords = GetEntityCoords(PlayerPedId())

            for _, entry in pairs(self.peds) do
                local npc, spawnDistance = entry.npc, entry.distance

                local distance = #(npc.position.coords - playerCoords)

                if distance <= spawnDistance and not npc.spawned and not npc.disabled then
                    npc:spawn()
                elseif distance > spawnDistance and npc.spawned or npc.disabled and npc.spawned then
                    npc:delete()
                end
            end

            Citizen.Wait(idle)
        end
    end)
end

function PedHandlers:stopThread()
    self.active = false

    Citizen.Wait(500)

    for _, entry in pairs(self.peds) do
        entry.npc:delete()
    end
end