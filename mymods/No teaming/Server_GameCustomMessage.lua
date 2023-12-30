function Server_GameCustomMessage(game, playerId, payload, setReturn)
	local host = game.ServerGame.Settings.StartedBy;

	if not (payload and game.Game.PlayingPlayers[payload.toEliminate] and (playerId and playerId == host)) then
		return setReturn(Mod.PlayerGameData);
	end

	local playerGD = Mod.PlayerGameData;
	playerGD[host].eliminating[payload.toEliminate] = payload.shouldEliminate or nil;
	Mod.PlayerGameData = playerGD;

	setReturn(Mod.PlayerGameData[host]);
end