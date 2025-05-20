require('settings');
require('tblprint');
require('ui');

require('util');
require('order_validation');

function Client_GameOrderCreated(game, order, skipOrder)
	if type(game.Settings.Cards) ~= 'table' then
		return;
	end

	if not (game.Us and game.Game.State == WL.GameState.Playing and game.Us.State == WL.GamePlayerState.Playing) then
		return;
	end

	local isValid = orderIsValidAgainstActiveCards(game, order, skipOrder);

	if not isValid then
		-- only show a single error message
		return;
	end

	for cardOrderIndex, cardOrder in ipairs(game.Orders) do
		validateOrderAgainstPlayedCard(game, cardOrder, order, skipOrder, cardOrderIndex);
	end
end

function orderIsValidAgainstActiveCards(game, order, skipOrder)
	local activeCardNames = {'Immobilize Card'};
	local isValid = true;

	for _, cardName in ipairs(activeCardNames) do
		local cardEnabled = getSetting(cardName .. 'sEnabled');
		local cardId = cardEnabled and getSetting(cardName .. 'ID');
		local card = cardId and game.Settings.Cards[cardId];
		local path = card and getKnownActiveCardsPath(card);

		if path then
			-- this fnName is a function name from require('order_validation')
			local fnName = 'OrderIsValidWhen' .. sanitizeCardName(card.Name) .. 'IsActive';

			print('about to call _G["' .. fnName .. '"](game, card, path, order, skipOrder)');
			isValid = _G[fnName](game, card, path, order, skipOrder);
			print('exited _G["' .. fnName .. '"](game, card, path, order, skipOrder)');
		end

		if not isValid then
			break;
		end
	end

	return isValid;
end

function getKnownActiveCardsPath(card)
	if not Mod.PlayerGameData then
		return;
	end

	if not Mod.PlayerGameData.KnownActiveCards then
		return;
	end

	local path = Mod.PlayerGameData.KnownActiveCards[card.Name];

	if not path then
		return;
	end

	return path;
end

function validateOrderAgainstPlayedCard(game, cardOrder, order, skipOrder, cardOrderIndex)
	local card = cardOrder.proxyType == 'GameOrderPlayCardCustom' and game.Settings.Cards[cardOrder.CardID];
	local isOwnPlayCardOrder = card and (Mod.Settings[card.Name .. 'sEnabled'] and card.CardID == Mod.Settings[card.Name .. 'ID']);

	if not isOwnPlayCardOrder then
		return;
	end

	-- this fnName is a function name from require('order_validation')
	local fnName = 'OrderIsValidWhen' .. sanitizeCardName(card.Name) .. 'Played';

	print('about to call _G["' .. fnName .. '"](game, card, cardOrder, order)');
	local isValid = _G[fnName](game, card, cardOrder, order);
	print('exited _G["' .. fnName .. '"](game, card, cardOrder, order)');

	if isValid then
		return;
	end

	skipOrder();
	game.CreateDialog(
		function(vert, setMaxSize, setScrollable)
			setMaxSize(480, 270) -- 16:9 on 30
			setScrollable(false, true);

			CustomCardHelpButton(card, Horz(vert), Vert(vert));

			Label(vert)
				.SetText('Order disallowed due to ' .. card.Name .. ' (order #'.. tostring(cardOrderIndex) .. ')')
				.SetColor('#FF0000');

			-- this fnName is a function name from require('order_validation')
			local fnName = 'MakeOrderIsInvalidWhen' .. sanitizeCardName(card.Name) .. 'PlayedMsg';

			print('about to call _G[' .. fnName .. '](game, vert, card, cardOrder, order, true)');
			_G[fnName](game, vert, card, cardOrder, order, true);
			print('exited _G[' .. fnName .. '](game, vert, card, cardOrder, order, true)');
		end
	);
end