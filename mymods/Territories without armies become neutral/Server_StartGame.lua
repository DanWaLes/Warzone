require 'util';
require 'version';

require 'terrHasNoArmies';

function Server_StartGame(game, standing)
	setup(game, standing);
end

function setup(game, standing)
	local playerForGameOrderCustoms = game.Settings.StartedBy;-- can't use neutral

	if not playerForGameOrderCustoms then
		for playerId in pairs(game.ServerGame.Game.Players) do
			playerForGameOrderCustoms = playerId;
			break;
		end
	end

	local publicGD = Mod.PublicGameData;

	publicGD.modCanDoChanges = (not game.Settings.OneArmyStandsGuard) or (game.Settings.OneArmyStandsGuard and game.Settings.Commanders);
	publicGD.initialIsSPAndCantRunMod = game.Settings.SinglePlayer and not canRunMod();
	publicGD.checkedAllTerritoriesForHavingNoArmies = false;
	publicGD.playerForGameOrderCustoms = playerForGameOrderCustoms;

	Mod.PublicGameData = publicGD;

	if not Mod.PublicGameData.modCanDoChanges then
		return;
	end

	-- turn all player owned territories that have no armies neutral
	for _, terr in pairs(standing.Territories) do
		if terrHasNoArmies(terr) then
			terr.OwnerPlayerID = WL.PlayerID.Neutral;
		end
	end
end