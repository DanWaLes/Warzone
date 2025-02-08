require('tblprint');
require('version');

local canRun;
local mysteryCardCardId;

function Server_AdvanceTurn_Start(game)
	canRun = serverCanRunMod(game);
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if not canRun then
		return;
	end

	if not (order.proxyType == 'GameOrderPlayCardCustom' and order.CardID == Mod.Settings.MysteryCardID) then
		return;
	end

	local playerId = order.PlayerID;

	if playerId == WL.PlayerID.Neutral then
		addNewOrder(WL.GameOrderEvent.Create(playerId, 'A mod tried to make Neutral play a Mystery Card but Neutral is unable to gain card pieces.'), true);

		return;
	end

	local player = game.ServerGame.Players[playerId];

	if not player then
		addNewOrder(WL.GameOrderEvent.Create(playerId, 'Tried to play a Mystery Card even though they are not in the game'), true);

		return;
	end

	if not (player.State == WL.GamePlayerState.Playing) then
		-- mystery card played during WL.TurnPhase.ReceiveCards so player might not be playing

		addNewOrder(WL.GameOrderEvent.Create(playerId, 'Unable to play Mystery Card as they are not playing'), true);

		-- playing a card on a teammates behalf could lead to potential card/order bugs
		-- so dont try to play the card on their behalf

		return;
	end

	local randomCard = decideRandomCard(game);
	local event = WL.GameOrderEvent.Create(playerId, 'Receive a full ' .. randomCard.name .. ' from playing a Mystery Card', {});
	local piecesInRandomCard = game.Settings.Cards[randomCard.id].NumPieces;

	event.addAddCardPiecesOpt = {[playerId] = {[randomCardId] = piecesInRandomCard}};
	addNewOrder(event, true);
end

function decideRandomCard(game)
	if not Mod.PublicGameData.cards then
		getCards(game);
	end

	return Mod.PublicGameData.cards[math.random(1, #Mod.PublicGameData.cards)];
end

function getCards(game)
	local cards = {};
	local pgd = Mod.PublicGameData;

	for cardId, cardGame in pairs(game.Settings.Cards) do
		if cardId ~= Mod.Settings.MysteryCardID then
			-- exclude Mystery Card

			table.insert({id = cardId, name = getCardName(cardGame)});
		end
	end

	Mod.PublicGameData.cards = cards;
end

function getCardName(cardGame)
	if cardGame.proxyType == 'CardGameCustom' then
		-- currently no standard way to get custom card name

		return 'card';
	end

	if cardGame.proxyType == 'CardGameAbandon' then
		-- Abandon card was the original name of the Emergency Blockade card

		return 'Emergency Blockade card';
	end

	cardGame.proxyType:gsub('^CardGame', ''):gsub('(%l)(%u)', '%1 %2') .. ' card';
end
