function Server_StartGame(game)
	local publicGameData = Mod.PublicGameData;
	publicGameData.votes = {};

	for playerId, player in pairs(game.ServerGame.Game.Players) do
		if not player.IsAI then
			-- ais automatially vote
			publicGameData.votes[playerId] = false;
		end
	end

	Mod.PublicGameData = publicGameData;
end