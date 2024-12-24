require('tblprint');

function Server_StartGame(game)
	local publicGameData = Mod.PublicGameData;

	publicGameData.votes = {};

	for playerId, _ in pairs(game.ServerGame.Game.Players) do
		publicGameData.votes[playerId] = false;
	end

	Mod.PublicGameData = publicGameData;
end
