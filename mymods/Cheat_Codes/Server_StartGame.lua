function Server_StartGame(game)
	local privateGameData = Mod.PrivateGameData;
	privateGameData.cheatCodes = generateCheatCodes(game);
	Mod.PrivateGameData = privateGameData;

	local playerGameData = Mod.PlayerGameData;

	for id, _ in pairs(game.ServerGame.Game.Players) do
		playerGameData[id] = {
			guessesSentThisTurn = {},
			solvedCheatCodesToDisplay = {},
			solvedCheatCodes = nil,
			codesToUse = {}
		};
	end

	Mod.PlayerGameData = playerGameData;
end

function generateCheatCodes(game)
	local cheatCodes = {};

	for id, _ in pairs(game.Settings.Cards) do
		local code = generateCheatCode();
		-- print(code);-- so that i can't cheat

		if not cheatCodes[code] then
			cheatCodes[code] = {};
		end

		table.insert(cheatCodes[code], id);
	end

	return cheatCodes;
end

function generateCheatCode()
	-- codes dont have to be unique
	local code = '';
	local i = 0;

	while true do
		if i == Mod.Settings.CheatCodeLength then
			break;
		end

		code = code .. math.random(0, 9);
		i = i + 1;
	end

	return code;
end