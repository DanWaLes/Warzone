require '_util';
require '_settings';

function Server_AdvanceTurn_End(game, addNewOrder)
	if not game.Settings.Cards then
		return;
	end

	local cardPiecesToAdd = {};
	local pgd = Mod.PublicGameData;

	for cardId, cardGame in pairs(game.Settings.Cards) do
		local cardName = string.sub(cardGame.proxyType, #'CardGame' + 1);

		if getSetting('Enable' .. cardName) then
			-- print(cardName .. ' is enabled');

			if not pgd.lastGivenCardPiecesOn[cardId] or (pgd.lastGivenCardPiecesOn[cardId] + getSetting('Freq' .. cardName) == game.ServerGame.Game.TurnNumber) then
				-- print('is time to give pieces of ' .. cardName);
				pgd.lastGivenCardPiecesOn[cardId] = game.ServerGame.Game.TurnNumber;

				for playerId in pairs(game.ServerGame.Game.PlayingPlayers) do
					if not cardPiecesToAdd[playerId] then
						cardPiecesToAdd[playerId] = {};
					end

					cardPiecesToAdd[playerId][cardId] = getSetting('Pieces' .. cardName);
				end
			else
				-- print('not time to give pieces of ' .. cardName);
			end
		end
	end

	for playerId, pieces in pairs(cardPiecesToAdd) do
		-- no order is created if no pieces are given

		local event = WL.GameOrderEvent.Create(playerId, 'Receive card pieces', game.Settings.HasAnySortOfFog and {} or nil);
		event.AddCardPiecesOpt = {[playerId] = pieces};
		addNewOrder(event);
	end

	Mod.PublicGameData = pgd;
end