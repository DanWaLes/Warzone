require('tblprint');
require('version');

local debug = false;

function Server_StartGame(game, standing)
	if game.Settings.MapTestingGame then
		if not debug then
			return;
		end
	end

	if not serverCanRunMod(game) then
		return;
	end

	for id, terr in pairs(standing.Territories) do
		standing.Territories[id].NumArmies = WL.Armies.Create(0);
		standing.Territories[id].OwnerPlayerID = WL.PlayerID.Neutral;
	end

	local n = 1;

	for id, player in pairs(game.ServerGame.Game.Players) do
		-- map choice when trying to create a game prevents n > #Mod.PublicGameData.terrNames from happening
		local terr = Mod.PublicGameData.terrNames[n];

		standing.Territories[terr.id].OwnerPlayerID = id;
		n = n + 1;
	end

	local pgd = Mod.PublicGameData;

	pgd.terrNo = n;
	pgd.numPlayers = n - 1;
	Mod.PublicGameData = pgd;
end
