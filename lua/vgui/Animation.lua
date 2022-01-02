CGLM.Animations = CGLM.Animations or {}
CGLM.animationsRenderGroup = CGLM.animationsRenderGroup or {}

Animation = {
    name = "",
    active = false,
    currentlyHung = false,

    duration = 1,
    durationStartTime = 0,
    durationProgress = 0,

    hangDuration = 1,
    hangDurationStartTime = 0,
    hangDurationProgress = 0,

    sound,
    material,

    defaultPosition = {
        x = 0,
        y = 0
    },
    targetPosition = {
        x = 0,
        y = 0
    }
}

function Animation:new(o)
    o = o or {} -- Variables set from initialisation will overshadow the base class'.
    setmetatable(o, self) -- (for new Object) Missing methods are looked up in the Animation table
    self.__index = self -- (for Animation) Any object that inherits this constructor will also have its index configured.
    CGLM.Animations[o.name] = o
    return o
end

function Animation:play()
    local startTime = RealTime()
    self.active = true
    self.currentlyHung = false -- TODO: Make implement a type of animation that starts off hung? Then reconsider this.

    self.durationStartTime = startTime
    self.hangDurationStartTime = startTime + self.duration

    self.durationProgress = 0
    self.hangDurationProgress = 0

    CGLM.animationsRenderGroup[self.name] = self
    surface.PlaySound(self.sound)
end

function Animation:draw()
    --print("Attempting to draw " .. self.name .. " AND its " .. tostring(self.active))
    if !self.active then return end

    if self.durationProgress >= 1 then
        self.hangDurationProgress = (RealTime() - self.hangDurationStartTime) / self.hangDuration
        surface.SetDrawColor(255,255,255,Lerp(1 - self.hangDurationProgress, 0, 255))
    else
        self.durationProgress = (RealTime() - self.durationStartTime) / self.duration
        surface.SetDrawColor(255,255,255,255)
    end

    surface.SetMaterial(self.material)
    surface.DrawTexturedRect(
        Lerp(self.durationProgress, self.defaultPosition.x, self.targetPosition.x),
        Lerp(self.durationProgress, self.defaultPosition.y, self.targetPosition.y),
        32, 32)

    if self.durationProgress >= 1 && self.hangDurationProgress >= 1 then
        self.active = false
        CGLM.animationsRenderGroup[self.name] = nil -- Should allow garbage collector to pass and collect this
    end
end

local function onPlayAnimation()
    local anim = net.ReadString()
    CGLM.Animations[anim]:play()
end
net.Receive("CGLM playAnimation", onPlayAnimation)

hook.Add("HUDPaintBackground","CGLM Animations", function() -- TODO: Change to attempt to only tick animations that are actually alive, instead of testing each one.
    for k, anim in pairs(CGLM.animationsRenderGroup) do
        anim:draw()
    end
end)
