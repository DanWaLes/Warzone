function setup(game)
	-- can't be in server created

	local hostPlayerId = game.ServerGame.Settings.StartedBy;

	if not hostPlayerId then
		return;
	end

	local host = game.ServerGame.Game.Players[hostPlayerId];
	local playerGD = {
		[hostPlayerId] = {
			eliminating = {}
		};
	};

	Mod.PlayerGameData = playerGD;

	local publicGD = {
		teams = {}
	};

	for _, player in pairs(game.ServerGame.Game.Players) do
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

	Mod.PublicGameData = publicGD;
end