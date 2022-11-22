require 'util';

function Server_GameCustomMessage(game, playerId, payload, setReturn)
	if not payload then
		return;
	end

	local ret = {};

	if payload.enterCode ~= nil then
		ret = codeEntered(playerId, payload.enterCode);
	elseif payload.deleteCode ~= nil then
		ret = deleteCode(playerId, payload.deleteCode);
	end

	setReturn(ret);
end

function codeEntered(playerId, code)
	local playerGameData = Mod.PlayerGameData;
	local codeNo = tbllen(playerGameData[playerId].codesEnteredThisTurn);

	if codeNo >= Mod.Settings.CheatCodeGuessesPerTurn then
		return {};
	end

	playerGameData[playerId].codesEnteredThisTurn[code] = 1;-- makes deleting a code faster

	if playerGameData[playerId].solvedCheatCodes[code] then
		playerGameData[playerId].codesToUseThisTurn[code] = 1;
	else
		playerGameData[playerId].guessesThisTurn[code] = 1;

		if Mod.PrivateGameData.cheatCodes[code] then
			playerGameData[playerId].correctGuessesThisTurn[code] = 1;
		end
	end

	Mod.PlayerGameData = playerGameData;

	return Mod.PlayerGameData[playerId].codesEnteredThisTurn;
end

function deleteCode(playerId, code)
	local playerGameData = Mod.PlayerGameData;

	playerGameData[playerId].codesEnteredThisTurn[code] = nil;
	playerGameData[playerId].codesToUseThisTurn[code] = nil;
	playerGameData[playerId].guessesThisTurn[code] = nil;
	playerGameData[playerId].correctGuessesThisTurn[code] = nil;

	Mod.PlayerGameData = playerGameData;
	return Mod.PlayerGameData[playerId].codesEnteredThisTurn;
end