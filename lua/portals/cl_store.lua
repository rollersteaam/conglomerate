local sounds = {
	onMenuOpen = Sound("ui/menu_onOpen.mp3"),
	onMenuClose = Sound("ui/menu_onClose.mp3")
}

local materials = {
	banner = Material("menu/crownApparelBanner.png"),
	purchased = Material("icon16/accept.png")
}

local softLimitX = 700
local softLimitY = 500
local spacing = 64
local items = {}

local itemDescription
local itemNameText

local currentlySelected
local function itemSelect(item)
	if currentlySelected != nil then
		currentlySelected.backgroundComponent:SetVisible(false)
	end

	itemNameText:SetText(item.name)
	itemNameText:SizeToContents()

	itemNameText.background:SetText(item.name)
	itemNameText.background:SizeToContents()

	itemDescription:SetText(item.description)

	item.backgroundComponent:SetVisible(true)
	currentlySelected = item
end

local randomNames = {
	"The Appraiser",
	"The Colonel",
	"Major"
}

local function drawShopItems(parent)
	items = {}
	local finished = false
	for row = 0, 99 do
		items[row] = {}
		for column = 0,99 do
			local itemBackground = vgui.Create("DPanel", parent)
			itemBackground:SetPos((spacing + 64 * column) + 485,(spacing + 64 * row) - 33)
			itemBackground:SetSize(64,64)
			itemBackground:SetVisible(false)
			itemBackground.Paint = function(self, w, h)
				draw.RoundedBox(0,0,0,w,h,Color(244,173,66))
			end

			local Item = items[row][column]
			Item = vgui.Create("DModelPanel", parent)
			Item:SetPos((spacing + 64 * column) + 485,(spacing + 64 * row) - 33)
			Item:SetSize(64,64)
			Item:SetModel(LocalPlayer():GetModel())
			Item.DoClick = function()
				surface.PlaySound(sounds.onMenuClose)
				itemSelect(Item)
			end

			local purchasedIcon = vgui.Create("DImage", Item)
			purchasedIcon:SetSize(16,16)
			purchasedIcon:SetMaterial(materials.purchased)
			purchasedIcon:SetVisible(false)

			Item.backgroundComponent = itemBackground
			Item.name = randomNames[math.random(1,3)]
			print(Item.name)
			Item.description = "I'm sure this will look great on you. Go for it, I dare you."
			Item.purchased = false
			Item.purchasedIcon = purchasedIcon

			if spacing + 64 * (column + 1) > softLimitX then
				if spacing + 64 * row > softLimitY then
					finished = true
					break
				end

				break
			end
		end
		if finished then break end
	end
end

function drawStore(portalMenu)
	local main = vgui.Create("DFrame")
	main:SetSize(1200, 600)
	main:Center()
	main:SetTitle("Crown Apparel")
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
		currentlySelected = nil
		menuActive = false
		portalMenu()
	end

	local mainCloseButton = vgui.Create("DButton", main)
	mainCloseButton:SetPos(1156, 2)
	mainCloseButton:SetSize(40,20)
	mainCloseButton:SetText("X")
	function mainCloseButton:DoClick()
		surface.PlaySound(sounds.onMenuClose)
		main:Close()
	end
	function mainCloseButton:Paint(w,h)
		draw.RoundedBox(0,0,0,w,h,Color(230,230,230))
	end

	local banner = vgui.Create("DImage", main)
	banner:SetMaterial(materials.banner)
	banner:SetPos(2,24)
	banner:SetSize(540, 160)

	local itemNameTextBackground = vgui.Create("DLabel", main)
	itemNameTextBackground:SetPos(21, 201)
	itemNameTextBackground:SetText("Please select an item.")
	itemNameTextBackground:SetFont("DermaLarge")
	itemNameTextBackground:SetTextColor(Color(135,135,135))
	itemNameTextBackground:SizeToContents()

	itemNameText = vgui.Create("DLabel", main)
	itemNameText:SetPos(20, 200)
	itemNameText:SetText("Please select an item.")
	itemNameText:SetFont("DermaLarge")
	itemNameText:SetTextColor(Color(244,173,66))
	itemNameText:SizeToContents()

	itemNameText.background = itemNameTextBackground

	itemDescription = vgui.Create("DLabel", main)
	itemDescription:SetPos(15, 235)
	itemDescription:SetSize(400, 600)
	itemDescription:SetFont("DermaLarge")
	itemDescription:SetText("Selecting an item will show its description.")
	itemDescription:SetAutoStretchVertical(true)
	itemDescription:SetTextColor(Color(135,135,135))
	itemDescription:SetWrap(true)

	local itemPurchaseButton = vgui.Create("DButton", main)
	itemPurchaseButton:SetPos(0, 558)
	itemPurchaseButton:SetSize(540, 40)
	itemPurchaseButton:SetText("Purchase")
	itemPurchaseButton:SetFont("DermaLarge")
	itemPurchaseButton:SetTextColor(Color(255,255,255))
	itemPurchaseButton.DoClick = function()
		if currentlySelected == nil then return end
		currentlySelected.purchased = true
		currentlySelected.purchasedIcon:SetVisible(true)
		CGLM.Animations["onCrownsRemoved"]:play()
		surface.PlaySound(sounds.onMenuOpen)
		net.Start("CGLM Purchase")
		net.SendToServer()
	end
	function itemPurchaseButton:Paint(w, h)
		draw.RoundedBox(4,0,0,w,h,Color(244,173,66))
	end

	drawShopItems(main)
end
