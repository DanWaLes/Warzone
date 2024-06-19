function setup(game)
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

	local wasSetUp = Mod.PublicGameData and Mod.PublicGameData[hostPlayerId];

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

	local publicGD = {
		teams = {}
	};

	for _, player in pairs(game.ServerGame.Game.PlayingPlayers) do
		if not playerGD[player.ID] then
			playerGD[player.ID] = {};
		end

		if player.Team ~= -1 then
			if not publicGD.teams[player.Team] then
				publicGD.teams[player.Team] = 0;
			end

			publicGD.teams[player.Team] = publicGD.teams[player.Team] + 1;

			if host.Team == player.Team and publicGD.teams[player.Team] > 1 then
				-- only need to know if there's more than 1 player on host's team
				break;
			end
		end
	end

	Mod.PlayerGameData = playerGD;
	Mod.PublicGameData = publicGD;

	print('Mod.PlayerGameData');
	tblprint(Mod.PlayerGameData);
	print('Mod.PublicGameData');
	tblprint(Mod.PublicGameData);
end
