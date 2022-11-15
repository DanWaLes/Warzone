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
		local guessed = arrayToStrList(stored.guessesSentThisTurn);
		local solved = arrayToStrList(stored.solvedCheatCodesToDisplay);

		if guessed ~= '' then
			addNewOrder(WL.GameOrderEvent.Create(playerId, 'Guessed cheat codes: ' .. guessed, guessVisibility));

			if solved ~= '' then
				addNewOrder(WL.GameOrderEvent.Create(playerId, 'Solved cheat codes: ' .. solved, solvedVisibility));

				for i, code in pairs(stored.solvedCheatCodesToDisplay) do
					if not playerGameData[playerId].solvedCheatCodes then
						playerGameData[playerId].solvedCheatCodes = {};
					end

					playerGameData[playerId].solvedCheatCodes[code] = 1;
				end
			end
		end

		playerGameData[playerId].guessesSentThisTurn = {};
		playerGameData[playerId].solvedCheatCodesToDisplay = {};
	end

	for playerId, stored in pairs(playerGameData) do
		for codeUsed, _ in pairs(stored.codesToUse) do
			-- https://www.warzone.com/wiki/Mod_API_Reference:GameOrderReceiveCard
			-- local cards = {};

			for _, cardId in pairs(Mod.PrivateGameData.cheatCodes[codeUsed]) do
				addNewOrder(WL.GameOrderEvent.Create(playerId, 'Used a cheat code', nil));
				local cardInstance;

				if cardId == WL.CardID.Reinforcement then
					cardInstance = WL.ReinforcementCardInstance.Create(decideRCVal(game));
				else
					cardInstance = WL.NoParameterCardInstance.Create(cardId);
				end

				-- table.insert(cards, cardInstance);
				addNewOrder(WL.GameOrderReceiveCard.Create(playerId, {cardInstance}));-- this is fine
			end

			-- addNewOrder(WL.GameOrderReceiveCard.Create(playerId, cards));-- this breaks
		end

		playerGameData[playerId].codesToUse = {};
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