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
end