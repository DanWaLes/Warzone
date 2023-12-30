function setup(game)
	-- can't be in server created

	local host = game.ServerGame.Settings.StartedBy;

	if not host then
		return;
	end

	local playerGD = {
		[host] = {
			eliminating = {[host] = true}
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
		end
	end

	Mod.PublicGameData = publicGD;
end