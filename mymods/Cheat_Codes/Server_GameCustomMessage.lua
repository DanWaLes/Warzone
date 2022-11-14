function Server_GameCustomMessage(game, playerId, payload)
	if not payload then
		return;
	end

	if payload.guess ~= nil then
		processGuess(playerId, payload.guess);
	end
end

function processGuess(playerId, guess)
	local playerGameData = Mod.PlayerGameData;
	local guessNo = #playerGameData[playerId].guessesSentThisTurn;

	print('server guessNo = ' .. guessNo + 1);
	--print('server guess = ' .. guess);

	if guessNo >= Mod.Settings.CheatCodeGuessesPerTurn then
		print('ran out of guesses');
		return;
	end

	table.insert(playerGameData[playerId].guessesSentThisTurn, guess);

	local solved = Mod.PrivateGameData.cheatCodes[guess] ~= nil;

	if solved then
		table.insert(playerGameData[playerId].solvedCheatCodesToDisplay, guess);
	end

	Mod.PlayerGameData = playerGameData;

	local guesses = Mod.PlayerGameData[playerId].guessesSentThisTurn;
	local str = '';

	for i, guess in pairs(guesses) do
		str = str .. guess;

		if i < #guesses then
			str = str .. ', ';
		end
	end

	print('all server guesses = ' .. str);
end