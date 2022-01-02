util.AddNetworkString("CGLM.syncLocalData")

local function updateLocalEntityData(ply)
	timer.Simple(1, function() // This net message uses networked values, which have a small update delay.
		net.Start("CGLM.syncLocalData")
		net.Send(ply)
	end)
end

local function formatSteamID(ply)
	return string.gsub(ply:SteamID(),":","")
end

local function syncEntityData(ply)
	local playerData = {}
	playerData.crowns = ply:GetNWInt("Crowns")
	playerData.level = ply:GetNWInt("CGLM level")
	playerData.totalCrownsEarned = ply:GetNWInt("CGLM totalCrownsEarned")
	playerData.minutesPlayed = ply:GetNWInt("CGLM minutesPlayed")
	file.Write("Conglomerate/" .. formatSteamID(ply) .. ".txt", util.TableToJSON(playerData))
end

util.AddNetworkString("CGLM updateMinutesPlayed")

local function initialSyncEntityData(ply)
	local formattedSteamID = formatSteamID(ply)
	local playerData = {}

	if file.Exists("Conglomerate/" .. formattedSteamID .. ".txt", "DATA") then
		playerData = util.JSONToTable(file.Read("Conglomerate/" .. formattedSteamID .. ".txt"))
	end

	ply:SetNWInt("CGLM minutesPlayed", playerData.minutesPlayed) // Prefixed to prevent compatibility issues (unlikely)
	ply:SetNWInt("CGLM totalCrownsEarned", playerData.totalCrownsEarned)
	ply:SetNWInt("Crowns", playerData.crowns)
	ply:SetNWInt("CGLM level", playerData.level)
	updateLocalEntityData(ply)

	timer.Create("playtimeTracker_" .. formattedSteamID,60,0,function()
		ply:SetNWInt("CGLM minutesPlayed", ply:GetNWInt("CGLM minutesPlayed") + 1)
		net.Start("CGLM updateMinutesPlayed")
		net.Send(ply)
		syncEntityData(ply)
	end)
end
hook.Add("PlayerInitialSpawn", "Conglomerate Initial Sync Data To Client", function(ply)
	timer.Simple(1, function() initialSyncEntityData(ply) end)
end)

local function onPlayerDisconnected(ply)
	timer.Remove("playtimeTracker_" .. formatSteamID(ply))
end
hook.Add("PlayerDisconnected","playtimeTrackerDestroyer",onPlayerDisconnected)

local function playerChatCommands(senderEntity, text)
	if (string.sub(text,0,3) == "/cr") then
		senderEntity:modifyCrowns(tonumber(string.sub(text,5)))
		return ""
	end
end
hook.Add("PlayerSay","Conglomerate modifyCrowns Chat Command", playerChatCommands)

local PlayerClass = FindMetaTable("Player")

util.AddNetworkString("CGLM Animations addCrowns")
util.AddNetworkString("CGLM Animations removeCrowns")

function PlayerClass:levelUp()
	local playerData = {}
	playerData.level = self:GetNWInt("CGLM level")
	playerData.totalCrownsEarned = self:GetNWInt("CGLM totalCrownsEarned")

	playerData.level = playerData.level + 1
	self:SetNWInt("CGLM level", playerData.level)

	net.Start("CGLM levelUp")
	net.Send(self)

	local amountToLevel = 100 * math.pow(1.2, playerData.level)
	if playerData.totalCrownsEarned > amountToLevel then
		self:levelUp()
	end
	syncEntityData(self)
end

function PlayerClass:modifyCrowns(amt)
	local crowns = tonumber(amt)
	if crowns == nil then return end

	local playerData = {}
	playerData.crowns = self:GetNWInt("Crowns")
	playerData.level = self:GetNWInt("CGLM level")
	playerData.totalCrownsEarned = self:GetNWInt("CGLM totalCrownsEarned")

	playerData.crowns = playerData.crowns + crowns // Update our cached copy so it may be used again without needing to access NW
	self:SetNWInt("Crowns", playerData.crowns)

	if amt > 0 then
		playerData.totalCrownsEarned = playerData.totalCrownsEarned + amt
		self:SetNWInt("CGLM totalCrownsEarned", playerData.totalCrownsEarned)

		local amountToLevel = 100 * math.pow(1.2, playerData.level)
		if playerData.totalCrownsEarned > amountToLevel then
			self:levelUp()
		end

		net.Start("CGLM Animations addCrowns")
			net.WriteInt( math.max(math.Round(amt / 100), 1), 8 )
		net.Send(self)
	else
		net.Start("CGLM Animations removeCrowns")
		net.Send(self)
	end

	updateLocalEntityData(self)
	syncEntityData(self)
end
