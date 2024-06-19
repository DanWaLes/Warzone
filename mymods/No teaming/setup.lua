require '_util';

function setup(game)
	local publicGD = Mod.PublicGameData or {};
	publicGD.FixedSetupStorage = true;
	Mod.PublicGameData = publicGD;

	local hostPlayerId = game.ServerGame.Settings.StartedBy;

	if not hostPlayerId then
		print('exit 1');
		return;
	end

	local host = game.ServerGame.Game.Players[hostPlayerId];

	if not host then
		print('exit 2');
		return;
	end

	local wasSetUp = Mod.PlayerGameData and Mod.PlayerGameData[hostPlayerId];

	if wasSetUp and (not (game.ServerGame.State == WL.GameState.DistributingTerritories or game.ServerGame.State == WL.GameState.Playing)) then
		print('exit 3');
		print('game.ServerGame.State', game.ServerGame.State);
		print('WL.GameState.DistributingTerritories', WL.GameState.DistributingTerritories);
		print('WL.GameState.Playing', WL.GameState.Playing);
		return;
	end

	local playerGD = {
		[hostPlayerId] = {
			eliminating = {}
		};
	};

	local teams = {};

	for _, player in pairs(game.ServerGame.Game.PlayingPlayers) do
		if not playerGD[player.ID] then
			playerGD[player.ID] = {};
		end

		if player.Team ~= -1 then
			if not teams[player.Team] then
				teams[player.Team] = 0;
			end

			teams[player.Team] = teams[player.Team] + 1;

			if host.Team == player.Team and teams[player.Team] > 1 then
				-- only need to know if there's more than 1 player on host's team
				break;
			end
		end
	end

	Mod.PlayerGameData = playerGD;
	local publicGD = Mod.PublicGameData;
	publicGD.teams = teams;
	Mod.PublicGameData = publicGD;

	print('Mod.PlayerGameData');
	tblprint(Mod.PlayerGameData);
	print('Mod.PublicGameData');
	tblprint(Mod.PublicGameData);
end
