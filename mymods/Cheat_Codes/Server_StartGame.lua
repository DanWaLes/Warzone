function Server_StartGame(game)
	local cheatCodes = generateCheatCodes(game);

	local publicGameData = Mod.PublicGameData;
	publicGameData.numCheatCodes = cheatCodes.length;
	Mod.PublicGameData = publicGameData;

	local privateGameData = Mod.PrivateGameData;
	privateGameData.cheatCodes = cheatCodes.codes;
	Mod.PrivateGameData = privateGameData;

	local playerGameData = Mod.PlayerGameData;

	for id, _ in pairs(game.ServerGame.Game.Players) do
		playerGameData[id] = {
			codesEnteredThisTurn = {},
			correctGuessesThisTurn = {},
			guessesThisTurn = {},-- correct and incorrect guesses
			codesToUseThisTurn = {},-- must be solved to use them
			solvedCheatCodes = {}-- all solved throughout the course of the game
		};
	end

	Mod.PlayerGameData = playerGameData;
end

function generateCheatCodes(game)
	local cheatCodes = {
		codes = {},
		length = 0
	};

	for id, _ in pairs(game.Settings.Cards) do
		local code = generateCheatCode();
		print(code);-- for debugging, remove this before making it completely public

		if not cheatCodes.codes[code] then
			cheatCodes.codes[code] = {};
			cheatCodes.length = cheatCodes.length + 1;
		end

		table.insert(cheatCodes.codes[code], id);
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