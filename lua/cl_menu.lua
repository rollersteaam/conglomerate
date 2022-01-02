local menuActive = false

local sounds = {
    onMenuOpen = Sound("ui/menu_onOpen.mp3"),
    onMenuClose = Sound("ui/menu_onClose.mp3")
}

local materials = {
    preview = Material("menu/preview.png"),
    crownApparel = Material("menu/crownApparel.png"),
    kingsGym = Material("menu/kingsGym.png")
}

local function drawStatusPanel(parent)
    local status = vgui.Create("DPanel",parent)
    status:SetPos(232,24)
    status:SetSize(370,75)
    function status:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,Color(135,135,135))
    end

    local statusText = vgui.Create("DLabel",status)
    statusText:SetPos(55, 5)
    statusText:SetText(LocalPlayer():Nick())
    statusText:SetFont("DermaLarge")
    statusText:SetTextColor(Color(255,255,255))
    statusText:SizeToContents()

    local statusPicture = vgui.Create("AvatarImage",status)
    statusPicture:SetPos(14,4)
    statusPicture:SetSize(32,32)
    statusPicture:SetPlayer(LocalPlayer(),32)

    local stats = vgui.Create("DLabel", status)
    stats:SetPos(14,37)
    stats:SetText("Statistics")
    stats:SetFont("Default")
    stats:SetTextColor(Color(244,173,66))
    stats:SizeToContents()

    local separator = ":"
    if (CGLM.localPlayerData.minutesPlayed % 60 < 10) then
        separator = ":0"
    end

    local timePlayed = vgui.Create("DLabel", status)
    timePlayed:SetPos(14,47)
    timePlayed:SetFont("Default")
    timePlayed:SetText("Time Played (h:m): ")
    timePlayed:SizeToContents()

    local timePlayed_stat = vgui.Create("DLabel", status)
    timePlayed_stat:SetPos(115,47)
    timePlayed_stat:SetFont("Default")
    timePlayed_stat:SetText(math.floor(CGLM.localPlayerData.minutesPlayed / 60) ..
        separator .. CGLM.localPlayerData.minutesPlayed % 60)
    timePlayed_stat:SetTextColor(Color(244,173,66))
    timePlayed_stat:SizeToContents()

    local totalGoldEarned = vgui.Create("DLabel", status)
    totalGoldEarned:SetPos(14,57)
    totalGoldEarned:SetFont("Default")
    totalGoldEarned:SetText("Total Crowns Earned: ")
    totalGoldEarned:SizeToContents()

    local totalGoldEarned_stat = vgui.Create("DLabel", status)
    totalGoldEarned_stat:SetPos(122,57)
    totalGoldEarned_stat:SetFont("Default")
    totalGoldEarned_stat:SetText(string.Comma(CGLM.localPlayerData.totalCrownsEarned))
    totalGoldEarned_stat:SetTextColor(Color(244,173,66))
    totalGoldEarned_stat:SizeToContents()
end

local function drawCrownsPanel(parent)
    local crowns = vgui.Create("DPanel",parent)
    crowns:SetPos(0,19)
    crowns:SetSize(242,85)
    function crowns:Paint(w, h)
        draw.RoundedBox(4,0,0,w,h,Color(244,173,66))
    end

    surface.SetFont("DermaLarge")
    local textWidth = surface.GetTextSize(string.Comma(CGLM.localPlayerData.crowns .. " CR"))

    local crownsText = vgui.Create("DLabel",crowns)
    crownsText:SetPos(121 - textWidth / 2, 25)
    crownsText:SetText(string.Comma(CGLM.localPlayerData.crowns .. " CR"))
    crownsText:SetFont("DermaLarge")
    crownsText:SetTextColor(Color(255,255,255))
    crownsText:SizeToContents()
end

local function mainMenu()
    menuActive = true

    local main = vgui.Create("DFrame")
    main:SetSize(604, 404)
    main:Center()
    main:SetTitle("Conglomerate")
    main:SetDraggable(false)
    main:SetSizable(false)
    main:ShowCloseButton(false)
    main:MakePopup()
    function main:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,Color(244,173,66))
        draw.RoundedBox(0,2,2,w - 4,h - 4,Color(230,230,230))
        draw.RoundedBox(4,0,0,w,24,Color(244,173,66))
    end
    function main:OnClose()
        menuActive = false
    end

    local mainCloseButton = vgui.Create("DButton", main)
    mainCloseButton:SetPos(562, 2)
    mainCloseButton:SetSize(40,20)
    mainCloseButton:SetText("X")
    function mainCloseButton:DoClick()
        surface.PlaySound(sounds.onMenuClose)
        main:Close()
    end
    function mainCloseButton:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,Color(230,230,230))
    end

    local longThumbnail = vgui.Create("DImage", main)
    longThumbnail:SetPos(15,115)
    longThumbnail:SetSize(181, 274)
    longThumbnail:SetMaterial(materials.preview)

    local crownApparelImage = vgui.Create("DImage", main)
    crownApparelImage:SetPos(211,115)
    crownApparelImage:SetSize(181, 274)
    crownApparelImage:SetMaterial(materials.crownApparel)

    local crownApparelPortal = vgui.Create("DButton", main)
    crownApparelPortal:SetPos(211, 115)
    crownApparelPortal:SetSize(181, 274)
    crownApparelPortal:SetText("")
    crownApparelPortal.DoClick = function()
        surface.PlaySound(sounds.onMenuClose)
        drawStore(mainMenu)
        main:Close()
    end
    function crownApparelPortal:Paint(w, h) // TODO: Implement a thick blue outline when hovered
    end

    local longThumbnail3 = vgui.Create("DImage", main)
    longThumbnail3:SetPos(407,115)
    longThumbnail3:SetSize(181, 274)
    longThumbnail3:SetMaterial(materials.kingsGym)

    drawStatusPanel(main)
    drawCrownsPanel(main)
    surface.PlaySound(sounds.onMenuOpen)
end

net.Receive("CGLM loadMenu", mainMenu)

local function playerInput()
    if input.IsKeyDown(KEY_F4) && !menuActive then
        mainMenu()
    end
end

hook.Add("Tick", "Conglomerate Player Input", playerInput)
