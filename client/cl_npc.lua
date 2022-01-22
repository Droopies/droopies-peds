Ped = {}

DecorRegister('NPC', 2)
DecorRegister('NPC_ID', 3)

function Ped:new(id, pedType, model, position, appearance, animation, networked, settings, qtarget, flags, scenario, blip)
    local this = {}

    this.id = id
    this.type = pedType
    this.model = GetHashKey(model)
    this.position = position
    this.appearance = appearance
    this.animation = animation
    this.networked = networked
    this.settings = settings
    this.qtarget = qtarget
    this.flags = flags
    this.scenario = scenario
    this.blip = blip

    this.entity = nil
    this.spawned = false
    this.disabled = false
    this.tasks = {}

    self.__index = self

    return setmetatable(this, self)
end

function Ped:spawn()
    if self.spawned then return end

    LoadEntityModel(self.model)

    local ped = CreatePed(self.type, self.model, self.position.coords, self.position.heading + 0.0, self.networked, false)

    Citizen.Wait(0)

    SetPedDefaultComponentVariation(ped)

    if DoesEntityExist(ped) then
        self.entity, self.spawned = ped, true

        DecorSetInt(self.entity, 'NPC_ID', GetHashKey(self.id))

        if self.settings then
            self:setSettings()
        end

        if self.appearance then
            self:setAppearance()
        end

        if self.animation then
            self:setAnimation(self.animation.testdic, self.animation.testanim)
        end

        if self.scenario then
            self:setScenario()
        end
        
        if self.qtarget then 
            exports['qtarget']:AddBoxZone(
            self.entity,
            self.position.coords,
            2,
            2,
            {
            name="TaxiNPC",
            heading=self.position.heading + 0.0,
            debugPoly=false,
            minZ=self.position.coords.z - 2,
            maxZ=self.position.coords.z + 2,
            },{
                options = self.qtarget.options,
                distance = self.qtarget.distance
            })
        end
    end

    SetModelAsNoLongerNeeded(self.model)
end

function Ped:delete()
    if not self.spawned then return end

    self.spawned = false
    if self.qtarget then
            exports['qtarget']:RemoveTargetEntity(self.entity,self.qtarget.options)
    end
    if DoesEntityExist(self.entity) then
        DeleteEntity(self.entity)
    end
end

function Ped:enable()
    self.disabled = false
end

function Ped:disable()
    self.disabled = true
end

function Ped:setSettings(settings)
    if settings then self.settings = settings end

    for _, flag in ipairs(self.settings) do
        self:setSetting(flag.mode, flag.active, self.settings)
    end
end

function Ped:setSetting(mode, active, settings)
    if mode == 'invincible' then
        SetEntityInvincible(self.entity, active)
    elseif mode == 'freeze' then
        FreezeEntityPosition(self.entity, active)
    elseif mode == 'ignore' then
        SetBlockingOfNonTemporaryEvents(self.entity, active)
    elseif mode == 'collision' then
        SetEntityCompletelyDisableCollision(self.entity, false, false)
        SetEntityCoordsNoOffset(self.entity, self.position.coords, false, false, false)
    end
end

function Ped:setAppearance(appearance)
    if appearance then self.appearance = appearance end

    for _, component in pairs(self.appearance) do
        self:setComponent(component.mode, table.unpack(component.params))
    end
end

function Ped:setComponent(mode, ...)
    if mode == 'component' then
        SetPedComponentVariation(self.entity, ...)
    elseif mode == 'prop' then
        SetPedPropIndex(self.entity, ...)
    elseif mode == 'blend' then
        SetPedHeadBlendData(self.entity, ...)
    elseif mode == 'overlay' then
        SetPedHeadOverlay(self.entity, ...)
    elseif mode == 'overlaycolor' then
        SetPedHeadOverlayColor(self.entity, ...)
    elseif mode == 'haircolor' then
        SetPedHairColor(self.entity, ...)
    elseif mode == 'eyecolor' then
        SetPedEyeColor(self.entity, ...)
    end
end

function Ped:addTask(id, task)
    if self.tasks[id] then self:removeTask(id) end

    self.tasks[id] = {id = id, active = false, task = task}
end

function Ped:removeTask(id)
    if not self.tasks[id] then return end

    self.tasks[id]['active'] = false
    self.tasks[id] = nil
end

function Ped:startTask(id)
    if not self.tasks[id] or self.tasks[id]['active'] then return end

    self.tasks[id]['active'] = true
    self.tasks[id]:task(self.tasks[id])
end

function Ped:stopTask(id)
    if not self.tasks[id] or not self.tasks[id]['active'] then return end

    self.tasks[id]['active'] = false
end

function Ped:setScenario()
    TaskStartScenarioInPlace(self.entity, self.scenario, 0, true)
end

function Ped:setAnimation(animDic, animIdx)

    RequestAnimDict(animDic)
    while not HasAnimDictLoaded(animDic) do
        Citizen.Wait(0)
    end

    if IsEntityPlayingAnim(self.entity, animDic, animIdx, 3) then
        ClearPedSecondaryTask(self.entity)
    else
        local animLength = GetAnimDuration(animDic, animIdx)
        TaskPlayAnim(self.entity, animDic, animIdx, 1.0, 1.0, -1, 1, -1, 0, 0, 0)
    end
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(0)
    end
end

function LoadEntityModel(model)
    if not HasModelLoaded(model) then
        RequestModel(model)

        while not HasModelLoaded do
            Citizen.Wait(0)
        end
    end
end