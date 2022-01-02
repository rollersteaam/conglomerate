if (SERVER) then return end
CGLM = {};

include("vgui/Animation.lua")
include("cl_hud.lua");
include("cl_playerData.lua");

include("cl_menu.lua")
include("portals/cl_store.lua")

local function onPlayAnimation()
    local anim = net.ReadString()
    CGLM.Animations[anim]:play()
end
net.Receive("CGLM playAnimation", onPlayAnimation)
