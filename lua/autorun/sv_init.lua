if (CLIENT) then return end
CGLM = {}

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_playerData.lua")
AddCSLuaFile("cl_menu.lua")
AddCSLuaFile("portals/cl_store.lua")
AddCSLuaFile("vgui/Animation.lua")

include("sv_playerData.lua")

resource.AddFile("sound/ui/hud_crownsChanged.mp3")
resource.AddFile("sound/ui/menu_onOpen.mp3")
resource.AddFile("sound/ui/menu_onClose.mp3")

resource.AddFile("materials/menu/preview.png")
resource.AddFile("materials/menu/crownApparel.png")
resource.AddFile("materials/menu/crownApparelBanner.png")

util.AddNetworkString("CGLM loadMenu")
util.AddNetworkString("CGLM Purchase")

--- CGLM Animations
-- playAnimation(Entity ply, Animation anim)
-- Requests client to discover and play VGUI animations that were previously created clientside.
util.AddNetworkString("CGLM playAnimation")
function CGLM.playAnimation(ply, anim)
    net.Start("CGLM playAnimation")
    net.WriteString(anim)
    net.Send(ply)
end
--

util.AddNetworkString("CGLM HUDMessage")
local function playerChatCommands(senderEntity, text)
    if (text == "/cong") then
        net.Start("CGLM loadMenu")
        net.Send(senderEntity)
        return ""
    end

    if (text == "/s") then
        net.Start("CGLM HUDMessage")
        net.Send(senderEntity)
        return ""
    end
end
hook.Add("PlayerSay","Conglomerate Main Chat Commands", playerChatCommands)

net.Receive("CGLM Purchase",function(len, ply)
    ply:modifyCrowns(-500)
end)
