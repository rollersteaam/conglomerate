CGLM.localPlayerData = {
	crowns = 0,
	level = 0,
	crownsToNextLevel = 0,
	minutesPlayed = 0,
	totalCrownsEarned = 0
};

local function syncLocalData()
	CGLM.localPlayerData.level = LocalPlayer():GetNWInt("CGLM level")
	CGLM.localPlayerData.crownsToNextLevel = LocalPlayer():GetNWInt("crownsToNextLevel")
	CGLM.localPlayerData.minutesPlayed = LocalPlayer():GetNWInt("CGLM minutesPlayed")
	CGLM.localPlayerData.totalCrownsEarned = LocalPlayer():GetNWInt("CGLM totalCrownsEarned")

	CGLM.Animations["onDatabaseSave"]:play() -- TODO: Reconsider this.
end
net.Receive("CGLM.syncLocalData", syncLocalData)
