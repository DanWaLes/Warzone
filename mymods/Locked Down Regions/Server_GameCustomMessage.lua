function Server_GameCustomMessage(game, playerId, payload, setReturn)
	if playerId ~= game.Settings.StartedBy then
		return;
	end

	local publicGD = Mod.PublicGameData;

	for key, value in pairs(payload) do
		publicGD[key] = value;
	end

	Mod.PublicGameData = payload;

	setReturn(Mod.PublicGameData);
end