require '_util';

function Server_GameCustomMessage(game, playerId, payload, setReturn)
	-- to track which territories need to be checked rather than looping through all orders

	if not payload then
		return;
	end

	if not payload.terrId then
		return;
	end

	local publicGD = Mod.PublicGameData;

	if not publicGD then
		publicGD = {};
	end

	if not publicGD.terrsToCheck then
		publicGD.terrsToCheck = {};
	end

	publicGD.terrsToCheck[payload.terrId] = true;
	Mod.PublicGameData = publicGD;
end