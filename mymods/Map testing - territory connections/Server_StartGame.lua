-- if there is a custom scenario remove it and match with the overwritten settings
-- give players territories alphabetically
require '_util';

function Server_StartGame(game, standing)
	for id, terr in pairs(standing.Territories) do
		standing.Territories[id].NumArmies = WL.Armies.Create(0);
		standing.Territories[id].OwnerPlayerID = WL.PlayerID.Neutral;
	end

	local n = 1;
	local numTerritories = #Mod.PublicGameData.terrNames;

	for id, player in pairs(game.ServerGame.Game.Players) do
		if n > numTerritories then
			-- map choice when trying to create a game prevents this from happening
			break;
		end

		local terr = Mod.PublicGameData.terrNames[n];

		standing.Territories[terr.id].OwnerPlayerID = id;
		n = n + 1;
	end

	Mod.PublicGameData.terrNo = n;
end