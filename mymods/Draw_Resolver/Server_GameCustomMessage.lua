function Server_GameCustomMessage(game, playerId, payload, setReturn)
	local publicGameData = Mod.PublicGameData;
	local changed;

	if type(payload.vote) == 'boolean' then
		changed = 'votes';
		publicGameData.votes[playerId] = payload.vote;
	end

	publicGameData.changed = changed;
	Mod.PublicGameData = publicGameData;

	if changed then
		setReturn(publicGameData[changed]);
	end
end