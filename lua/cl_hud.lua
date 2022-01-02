local scrW = ScrW()
local scrH = ScrH()

lastCrownTransaction = ""

local materials = {
	crowns = Material("icon16/coins.png"),
	crownsAdded = Material("icon16/coins_add.png"),
	crownsRemoved = Material("icon16/coins_delete.png"),
	onDatabaseSave = Material("icon16/database_save.png")
}

local sounds = {
	crowns = Sound("ui/hud_crownsChanged.mp3"),
	exp = Sound("expGain/riser.mp3")
}

local styles = {}
styles.crowns = {
	xCordThreshold = scrW - scrW / 5 - 20,
	yCordThreshold = scrH - scrH / 20 - 20
}

local animations = {}

animations.onDatabaseSave = animations.onDatabaseSave or Animation:new({
	name = "onDatabaseSave",
	duration = 0.4,
	hangDuration = 3,

	sound = sounds.crowns,
	material = materials.onDatabaseSave,

	defaultPosition = {
		x = styles.crowns.xCordThreshold - 32 - 5,
		y = styles.crowns.yCordThreshold + (scrH / 20 - 32) / 2
	},
	targetPosition = {
		x = styles.crowns.xCordThreshold - 32 - 5,
		y = styles.crowns.yCordThreshold + (scrH / 20 - 32) / 2
	}
})

animations.onCrownsAdded = animations.onCrownsAdded or Animation:new({
	name = "onCrownsAdded",
	duration = 0.4,
	hangDuration = 3,

	sound = sounds.crowns,
	material = materials.crownsAdded,

	defaultPosition = {
		x = styles.crowns.xCordThreshold - 32 - 5,
		y = styles.crowns.yCordThreshold + (scrH / 20 - 32) / 2
	},
	targetPosition = {
		x = styles.crowns.xCordThreshold,
		y = styles.crowns.yCordThreshold + (scrH / 20 - 32) / 2
	}
})

animations.onCrownsRemoved = animations.onCrownsRemoved or Animation:new({
	name = "onCrownsRemoved",
	duration = 0.4,
	hangDuration = 3,

	sound = sounds.crowns,
	material = materials.crownsRemoved,

	defaultPosition = {
		x = styles.crowns.xCordThreshold,
		y = styles.crowns.yCordThreshold + (scrH / 20 - 32) / 2
	},
	targetPosition = {
		x = styles.crowns.xCordThreshold - 32 - 5,
		y = styles.crowns.yCordThreshold + (scrH / 20 - 32) / 2
	}
})

local function addCrowns()
	local amount = net.ReadInt(8)
	local flip = true

	local newBalance
	timer.Simple(0.5, function() newBalance = LocalPlayer():GetNWInt("Crowns") end)

	for i = 1, amount do
		local yOffset = 0
		flip = !flip
		if (flip) then
			yOffset = 16
		end

		local xOffset = math.random(5,195)

		local crowns = vgui.Create("DImage")
		crowns:SetPos(styles.crowns.xCordThreshold + 5 + xOffset, styles.crowns.yCordThreshold - 100 - yOffset)
		crowns:SetSize(16,16)
		crowns:SetAlpha(0)
		crowns:SetMaterial(materials.crowns)
		crowns:AlphaTo(255,1)

		if i == amount then
			crowns.lastFrame = true
		end

		crowns:MoveTo(styles.crowns.xCordThreshold + 5 + xOffset,
			styles.crowns.yCordThreshold,
			math.random(100, 250) / 100,0,1,
			function()
				surface.PlaySound(sounds.exp)

				if crowns.lastFrame then
					CGLM.localPlayerData.crowns = newBalance
					return
				end

				CGLM.localPlayerData.crowns = CGLM.localPlayerData.crowns + 100
			end)

		timer.Simple(3.5, function() crowns:Remove() end)
	end
end
net.Receive("CGLM Animations addCrowns", addCrowns)

local function drawStatusPanel()
	local statusPanelMask = vgui.Create("DPanel")
	statusPanelMask:SetPos(styles.crowns.xCordThreshold, styles.crowns.yCordThreshold - 190)
	statusPanelMask:SetSize(scrW / 5, 200)
	statusPanelMask.Paint = function()
	end

	local statusPanel = vgui.Create("DPanel", statusPanelMask)
	-- statusPanel:SetPos(styles.crowns.xCordThreshold, styles.crowns.yCordThreshold)
	statusPanel:SetPos(0,200)
	statusPanel:SetSize(scrW / 5, 200)

	statusPanel:LerpPositions(1, true)
	statusPanel:AlignBottom()

	local header = vgui.Create("DLabel",statusPanel)
	header:SetPos(5,5)
	header:SetText("Congratulations!")
	header:SetFont("DermaLarge")
	header:SetTextColor(Color(110,180,110))
	header:SizeToContents()

	timer.Simple(2, function()
		statusPanelMask:Remove()
	end)
end
net.Receive("CGLM HUDMessage", drawStatusPanel)

surface.CreateFont("CongHUDLevel", {
	font = "Roboto",
	size = 52
})

local function drawCrowns()
	local crowns = string.Comma(CGLM.localPlayerData.crowns)
	surface.SetFont("DermaLarge")

	local allTextSize = {
		width = select("1", surface.GetTextSize(crowns .. " CR")),
		height = select("2", surface.GetTextSize(crowns .. " CR"))
	}

	local spacing  = {
		CR = surface.GetTextSize(crowns)
	}

	draw.RoundedBox(4,styles.crowns.xCordThreshold,styles.crowns.yCordThreshold,scrW / 5,scrH / 20,Color(100,100,100))
	draw.RoundedBox(4,styles.crowns.xCordThreshold,styles.crowns.yCordThreshold,allTextSize.width + 10,scrH / 20,Color(244,173,66))

	draw.DrawText("LV. 100", "CongHUDLevel",
	styles.crowns.xCordThreshold + 254,
	styles.crowns.yCordThreshold - 8 + 1,
	Color( 100, 100, 100, 135 ), TEXT_ALIGN_RIGHT)

	draw.DrawText("LV. 100", "CongHUDLevel",
	styles.crowns.xCordThreshold + 254,
	styles.crowns.yCordThreshold - 8,
	Color( 255, 255, 255, 135 ), TEXT_ALIGN_RIGHT)

	draw.DrawText("CR", "DermaLarge",
		styles.crowns.xCordThreshold + spacing.CR + 13 + 1,
		styles.crowns.yCordThreshold + (scrH / 20 - allTextSize.height) / 2 + 1, Color(100, 100, 100))
	draw.DrawText("CR", "DermaLarge",
		styles.crowns.xCordThreshold + spacing.CR + 13,
		styles.crowns.yCordThreshold + (scrH / 20 - allTextSize.height) / 2)

	draw.DrawText(crowns, "DermaLarge",
		styles.crowns.xCordThreshold + 3 + 1,
		styles.crowns.yCordThreshold + (scrH / 20 - allTextSize.height) / 2 + 1, Color(100, 100, 100))
	draw.DrawText(crowns, "DermaLarge",
		styles.crowns.xCordThreshold + 3,
		styles.crowns.yCordThreshold + (scrH / 20 - allTextSize.height) / 2)
end

local function HUDPaint()
	drawCrowns();
end

hook.Add("DrawOverlay", "Conglomerate HUD", HUDPaint);

net.Receive("CGLM updateMinutesPlayed", function()
	CGLM.localPlayerData.minutesPlayed = CGLM.localPlayerData.minutesPlayed + 1
end)
