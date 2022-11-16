require 'util';

function Server_GameCustomMessage(game, playerId, payload, setReturn)
	if not payload then
		return;
	end

	local ret = {};

	if payload.guess ~= nil then
		ret = processGuess(playerId, payload.guess);
	elseif payload.useCode ~= nil then
		local playerGameData = Mod.PlayerGameData;
		if not playerGameData[playerId].solvedCheatCodes then
			playerGameData[playerId].solvedCheatCodes = {};
		end

		if not playerGameData[playerId].solvedCheatCodes[payload.useCode] then
			print('cant use this code because youve not guessed it yet');
			return;
		end

		if not Mod.PrivateGameData.cheatCodes[payload.useCode] then
			-- hacked somehow
			return;
		end

		if playerGameData[playerId].codesToUse[payload.useCode] then
			-- hacked somehow
			return;
		end

		playerGameData[playerId].codesToUse[payload.useCode] = 1;
		Mod.PlayerGameData = playerGameData;
	elseif payload.deleteGuess ~= nil then
		local playerGameData = Mod.PlayerGameData;
		local index = indexOf(playerGameData[playerId].guessesSentThisTurn, payload.deleteGuess);

		if index > 0 then
			table.remove(playerGameData[playerId].guessesSentThisTurn, index);
			Mod.PlayerGameData = playerGameData;
		end

		ret = Mod.PlayerGameData[playerId].guessesSentThisTurn;
	end

	setReturn(ret);
end

function processGuess(playerId, guess)
	local playerGameData = Mod.PlayerGameData;
	local guessNo = #playerGameData[playerId].guessesSentThisTurn;

	-- print('server guessNo = ' .. guessNo + 1);

	if guessNo >= Mod.Settings.CheatCodeGuessesPerTurn then
		-- print('ran out of guesses');
		return {};
	end

	table.insert(playerGameData[playerId].guessesSentThisTurn, guess);

	local solved = Mod.PrivateGameData.cheatCodes[guess] ~= nil;

	if solved then
		table.insert(playerGameData[playerId].solvedCheatCodesToDisplay, guess);
	end

	Mod.PlayerGameData = playerGameData;

	return Mod.PlayerGameData[playerId].guessesSentThisTurn;
end