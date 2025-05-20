require('TerritoryOrBonusSelectionMenu');
require('tblprint');
require('settings');
require('ui');
require('string_util');

require('util');
require('order_validation');

function Client_PresentPlayCardUI(game, cardInstance, playCard, closeCardsDialog)
	if not game.Us or game.Game.State ~= WL.GameState.Playing or game.Us.State ~= WL.GamePlayerState.Playing then
		return;
	end

	-- need deploy order skip bug fix to be complete before continuing

	local card = game.Settings.Cards[cardInstance.CardID];

	if WL.IsVersionOrHigher('5.34') then
		-- always need to get territory/bonus from player before card can be played
		-- close cards dialog so that map selection is easier
		closeCardsDialog();
	end

	createPlayCardDialog(game, card, playCard);
end

function createPlayCardDialog(game, card, playCard)
	game.CreateDialog(
		function(rootParent, setMaxSize, setScrollable, _, close)
			local wz = {
				game = game,
				playCard = playCard,
				close = close
			};

			setMaxSize(800, 450);-- 16:9 on 50
			setScrollable(false, true);

			addPlayCardContent(rootParent, wz, card);
		end
	);
end

function addPlayCardContent(vert, wz, card)
	-- this fnName is a function name from this file
	local fnName = 'Play' .. sanitizeCardName(card.Name);

	print('about to call _G[' .. fnName .. '](vert, wz, card)');
	_G[fnName](vert, wz, card);
	print('exit _G[' .. fnName .. '](vert, wz, card)');
end

function warnTerrIsOwnTerr(wz, vert)
	local horz = Horz(vert);

	Label(horz).SetText('You can only');
	Label(horz).SetText('select one of your own territories').SetColor('#FF7D00');
end

function invalidSelectedTerrIsOwnTerr(terrDetails, wz, vert)
	local horz = Horz(vert);

	HighlightTerrBtn(wz.game, terrDetails.ID, horz);
	Label(horz)
		.SetText('is not one of your own territories!')
		.SetColor('#FF0000');
end

function warnTerrIsOwnTerrOrConnected(wz, vert)
	local horz = Horz(vert);

	Label(horz).SetText('You can only');
	Label(horz).SetText('select one of your own territories').SetColor('#FF7D00');
	Label(horz).SetText('or');
	Label(horz).SetText('select a territory connected to your own territories').SetColor('#FF7D00');
end

function invalidSelectedTerrIsOwnTerrOrConnected(terrDetails, wz, vert)
	local horz = Horz(vert);

	HighlightTerrBtn(wz.game, terrDetails.ID, horz);
	Label(horz)
		.SetText('is not one of your own territories or connected to your own territories!')
		.SetColor('#FF0000');
end

function playSingleTerritoryTerritroySelectionCard(wz, card, vert, terrValidation)
	CustomCardHelpButton(card, Horz(vert), Vert(vert));

	local horz = Horz(vert);

	Label(horz).SetText('Select a territory you want to play ' .. aAn(card.Name));
	Label(horz).SetText(card.Name).SetColor('#00FF05');
	Label(horz).SetText('on');

	TerritorySelectionMenu(vert, terrValidation, wz);
end

function PlayReconnaissanceCard(vert, wz, card)
	if getSetting(card.Name .. 'RandomAutoplay') then
		CustomCardHelpButton(card, Horz(vert), Vert(vert));

		Label(vert).SetText(card.Name .. 's will be automatically randomly played, due to game settings');
		Label(vert).SetText('Discarding the card can be used to stay within the maximum cards held limit');
		-- not possible to prevent discard unless ignore all discard card orders
		-- or use a very hacky workaround
		Label(vert).SetText('As the turn advances, discarding the card will prevent Neutral from playing the card');
		Label(vert).SetText('Neutral will play the card on a random territory');
		Label(vert).SetText('Note that when Neutral plays the card, the name of the card owner is mentioned in order details');
		Label(vert).SetText('All players will be able to see the territories made visible');

		return;
	end

	local phase = WL.TurnPhase.SpyingCards;
	local orderIndex;
	local terrValidation = {
		isValidTerr = function(terrDetails, wz)
			-- this fnName is a function name from require('order_validation');
			local fnName = 'OrderIsValidWhen' .. sanitizeCardName(card.Name) .. 'Played';
			local fakeCardOrder = {CardID = card.CardID, ModData = tostring(terrDetails.ID)};

			for i, order in pairs(wz.game.Orders) do
				local isValid = _G[fnName](wz.game, card, fakeCardOrder, order);

				if not isValid then
					orderIndex = i;
					return;
				end

				if order.OccursInPhase and (order.OccursInPhase > phase) then
					-- can early exit because only used to check if not already played on same territory
					break;
				end
			end

			return true;
		end,
		onValidTerr = function(terrDetails)
			wz.close();
			wz.playCard('Play ' .. aAn(card.Name, true) .. ' on ' .. terrDetails.Name.. addDuration(card), tostring(terrDetails.ID), phase);
		end,
		onInvalidTerr = function(terrDetails, wz, vert)
			-- this fnName is a function name from require('order_validation');
			local fnName = 'MakeOrderIsInvalidWhen' .. sanitizeCardName(card.Name) .. 'PlayedMsg';
			local order = wz.game.Orders[orderIndex];
			local fakeCardOrder = {CardID = card.CardID, ModData = tostring(terrDetails.ID)};

			_G[fnName](wz.game, vert, card, fakeCardOrder, order, false);
		end
	};

	playSingleTerritoryTerritroySelectionCard(wz, card, vert, terrValidation);
end

function PlayRecycleCard(vert, wz, card)
	local phase = WL.TurnPhase.EmergencyBlockadeCards;
	local selectedTerrIsOwnTerr;
	local orderIndex;
	local terrValidation = {
		displayTerrSelectionWarning = warnTerrIsOwnTerr,
		isValidTerr = function(terrDetails, wz)
			selectedTerrIsOwnTerr = SelectedTerrIsOwnTerr(wz.game, terrDetails.ID);

			if not selectedTerrIsOwnTerr then
				return;
			end

			-- this fnName is a function name from require('order_validation');
			local fnName = 'OrderIsValidWhen' .. sanitizeCardName(card.Name) .. 'Played';
			local fakeCardOrder = {CardID = card.CardID, ModData = tostring(terrDetails.ID)};

			for i, order in pairs(wz.game.Orders) do
				local isValid = _G[fnName](wz.game, card, fakeCardOrder, order);

				if not isValid then
					orderIndex = i;
					return;
				end
			end

			return true;
		end,
		onValidTerr = function(terrDetails, wz)
			wz.close();
			wz.playCard('Play ' .. aAn(card.Name, true) .. ' on ' .. terrDetails.Name, tostring(terrDetails.ID), phase);
		end,
		onInvalidTerr = function(terrDetails, wz, vert)
			if not selectedTerrIsOwnTerr then
				return invalidSelectedTerrIsOwnTerr(terrDetails, wz, vert);
			end

			-- this fnName is a function name from require('order_validation');
			local fnName = 'MakeOrderIsInvalidWhen' .. sanitizeCardName(card.Name) .. 'PlayedMsg';
			local order = wz.game.Orders[orderIndex];
			local fakeCardOrder = {CardID = card.CardID, ModData = tostring(terrDetails.ID)};

			_G[fnName](wz.game, vert, card, fakeCardOrder, order, false);
		end
	};

	playSingleTerritoryTerritroySelectionCard(wz, card, vert, terrValidation);
end

function PlayImmobilizeCard(vert, wz, card)
	-- before any type of attack happens
	local phase = WL.TurnPhase.ReinforcementCards;
	local selectedTerrIsOwnTerrOrConnectedToOwnTerr;
	local orderIndex;
	local terrValidation = {
		displayTerrSelectionWarning = function(wz, vert)
			warnTerrIsOwnTerrOrConnected(wz, vert);
		end,
		isValidTerr = function(terrDetails, wz)
			selectedTerrIsOwnTerrOrConnectedToOwnTerr = SelectedTerrIsOwnTerrOrConnectedToOwnTerr(wz.game, terrDetails.ID);

			if not selectedTerrIsOwnTerrOrConnectedToOwnTerr then
				return;
			end

			-- this fnName is a function name from require('order_validation');
			local fnName = 'OrderIsValidWhen' .. sanitizeCardName(card.Name) .. 'Played';
			local fakeCardOrder = {CardID = card.CardID, ModData = tostring(terrDetails.ID)};

			for i, order in pairs(wz.game.Orders) do
				local isValid = _G[fnName](wz.game, card, fakeCardOrder, order);

				if not isValid then
					orderIndex = i;
					return;
				end
			end

			return true;
		end,
		onValidTerr = function(terrDetails)
			wz.close();
			wz.playCard('Play ' .. aAn(card.Name, true) .. ' on ' .. terrDetails.Name .. addDuration(card), tostring(terrDetails.ID), phase);
		end,
		onInvalidTerr = function(terrDetails, wz, vert)
			if not selectedTerrIsOwnTerrOrConnectedToOwnTerr then
				return invalidSelectedTerrIsOwnTerrOrConnected(terrDetails, wz, vert);
			end

			-- this fnName is a function name from require('order_validation');
			local fnName = 'MakeOrderIsInvalidWhen' .. sanitizeCardName(card.Name) .. 'PlayedMsg';
			local order = wz.game.Orders[orderIndex];
			local fakeCardOrder = {CardID = card.CardID, ModData = tostring(terrDetails.ID)};

			_G[fnName](wz.game, vert, card, fakeCardOrder, order, false);
		end
	};

	playSingleTerritoryTerritroySelectionCard(wz, card, vert, terrValidation);
end

function PlayTrapCard(vert, wz, card)
	-- before any type of attack happens
	local phase = WL.TurnPhase.ReinforcementCards;
	local selectedTerrIsOwnTerr;
	local orderIndex;
	local terrValidation = {
		displayTerrSelectionWarning = function(wz, vert)
			Label(vert).SetText('You can play the card multiple times on a territory. Each time an enemy captures the territory from you or a teammate, the card will activate again.');
			warnTerrIsOwnTerr(wz, vert);
		end,
		isValidTerr = function(terrDetails, wz)
			return SelectedTerrIsOwnTerr(wz.game, terrDetails.ID);
		end,
		onValidTerr = function(terrDetails)
			wz.close();
			wz.playCard('Play ' .. aAn(card.Name, true) .. ' on ' .. terrDetails.Name, tostring(terrDetails.ID), phase);
		end,
		onInvalidTerr = function(terrDetails, wz, vert)
			invalidSelectedTerrIsOwnTerr(terrDetails, wz, vert);
		end
	};

	playSingleTerritoryTerritroySelectionCard(wz, card, vert, terrValidation);
end

function PlayRushedBlockadeCard(vert, wz, card)
	local phase = WL.TurnPhase.Attacks;
	local terrValidation = {
		displayTerrSelectionWarning = function(wz, vert)
			Label(vert)
				.SetText('You must own the territory at the time of the card being played')
				.SetColor('#FF7D00');
		end,
		isValidTerr = function(terrDetails, wz)
			-- trying to do order validation to make sure card isnt useless can be unpredictable
			-- partly because of playing of other cards by players who arent on the same team
			-- partly because of happening during attacks
			-- so just allow any

			return true;
		end,
		onValidTerr = function(terrDetails)
			wz.close();
			wz.playCard('Play ' .. aAn(card.Name, true) .. ' on ' .. terrDetails.Name, tostring(terrDetails.ID), phase);
		end
	};

	playSingleTerritoryTerritroySelectionCard(wz, card, vert, terrValidation);
end