require 'util'

function Server_AdvanceTurn_End(game, addNewOrder)
	local playerGameData = Mod.PlayerGameData;
	local guessVisibility = nil;
	local solvedVisibility = nil;

	if Mod.Settings.CheatCodeGuessVisibiltyIsTeamOnly then
		guessVisibility = {};
	end
	if Mod.Settings.CheatCodeSolvedVisibiltyIsTeamOnly then
		solvedVisibility = {};
	end

	for playerId, stored in pairs(playerGameData) do
		local serverPlayer = game.ServerGame.Game.Players[playerId];

		if serverPlayer.State == WL.GamePlayerState.Playing then
			displayGuesses(playerId, stored, guessVisibility, addNewOrder);
			playerGameData = displaySolvedCodes(playerId, playerGameData, stored.correctGuessesThisTurn, solvedVisibility, addNewOrder);
			useCode(playerGameData, playerId, addNewOrder, game);
		end

		playerGameData[playerId].codesEnteredThisTurn = {};
		playerGameData[playerId].guessesThisTurn = {};
		playerGameData[playerId].correctGuessesThisTurn = {};
		playerGameData[playerId].codesToUseThisTurn = {};
	end

	Mod.PlayerGameData = playerGameData;
end

function decideRCVal(game)
	local rc = game.Settings.Cards[WL.CardID.Reinforcement];

	if rc.Mode == 0 then
		-- fixed armies
		return rc.FixedArmies;
	elseif rc.Mode == 1 then
		-- progressive by territories owned by players
		return rc.ProgressivePercentage * numTerritoriesOwnedByPlayers(game.ServerGame.LatestTurnStanding.Territories);
	else
		-- progressive by turn no
		return rc.ProgressivePercentage * (game.ServerGame.Game.NumberOfLogicalTurns + 1);
	end
end

function numTerritoriesOwnedByPlayers(territories)
	local i = 0;

	for _, territory in pairs(territories) do
		if not territory.IsNeutral then
			i = i + 1;
		end
	end

	return i;
end

function displayGuesses(playerId, stored, guessVisibility, addNewOrder)
	local guessed = '';
	local i = 0;
	local numGuessed = tbllen(stored.guessesThisTurn);

	for code, _ in pairs(stored.guessesThisTurn) do
		guessed = guessed .. code;

		if i + 1 < numGuessed then
			guessed = guessed .. ', ';
		end

		i = i + 1;
	end

	if guessed ~= '' then
		addNewOrder(WL.GameOrderEvent.Create(playerId, 'Guessed cheat codes: ' .. guessed, guessVisibility));
	end
end

function displaySolvedCodes(playerId, playerGameData, correctGuesses, solvedVisibility, addNewOrder)
	local correct = '';
	local i = 0;
	local numCorrect = tbllen(correctGuesses);

	for code, _ in pairs(correctGuesses) do
		playerGameData[playerId].solvedCheatCodes[code] = 1;
		correct = correct .. code;

		if i + 1 < numCorrect then
			correct = correct .. ', ';
		end

		i = i + 1;
	end

	if correct ~= '' then
		addNewOrder(WL.GameOrderEvent.Create(playerId, 'Solved cheat codes: ' .. correct, solvedVisibility));
	end

	return playerGameData;
end

function useCode(playerGameData, playerId, addNewOrder, game)
	for codeUsed, _ in pairs(playerGameData[playerId].codesToUseThisTurn) do
		addNewOrder(WL.GameOrderEvent.Create(playerId, 'Used a cheat code', nil));

		for _, cardId in pairs(Mod.PrivateGameData.cheatCodes[codeUsed]) do
			-- https://www.warzone.com/wiki/Mod_API_Reference:GameOrderReceiveCard
			local cardInstance;

			if cardId == WL.CardID.Reinforcement then
				cardInstance = WL.ReinforcementCardInstance.Create(decideRCVal(game));
			else
				cardInstance = WL.NoParameterCardInstance.Create(cardId);
			end

			addNewOrder(WL.GameOrderReceiveCard.Create(playerId, {cardInstance}));
		end
	end
end