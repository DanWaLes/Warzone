function Server_GameCustomMessage(game, playerId, payload, setReturn)
	local host = game.ServerGame.Settings.StartedBy;

	if payload and payload.fixSetupStorage then
		require('setup');
		setup();
	end

	if not host or not Mod.PlayerGameData[playerId] then
		return setReturn({
			PlayerGameData = {},
			PublicGameData = Mod.PublicGameData
		});
	end

	if not payload then
		return setReturn({
			PlayerGameData = Mod.PlayerGameData[playerId],
			PublicGameData = Mod.PublicGameData
		});
	end

	local playerGD = Mod.PlayerGameData;

	if payload.toEliminate and game.Game.PlayingPlayers[payload.toEliminate] and (playerId and playerId == host) then
		playerGD[host].eliminating[payload.toEliminate] = payload.shouldEliminate or nil;
	end

	Mod.PlayerGameData = playerGD;

	setReturn({
		PlayerGameData = Mod.PlayerGameData[host],
		PublicGameData = Mod.PublicGameData
	});
end
