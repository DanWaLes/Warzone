require "LoseArmiesPerTerritory"

-- set initial Mod data (manual dist only) - called in manual dist only

function Server_StartDistribution(game, standing)
	SetInitialStorage(game);
	-- note that when the game starts, the displayed Gold is incorrect, afterwards the displayed amount is correct and removes the correct amount of Gold
end