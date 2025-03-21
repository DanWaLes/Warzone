require('tblprint');
require('eliminate');
require('settings');
require('string_util');
require('number_util');

require('util');

local turnNum;

-- players who are no longer alive can make orders

function Server_AdvanceTurn_Start(game, addNewOrder)
	if type(game.Settings.Cards) ~= 'table' then
		return;
	end

	turnNum = game.ServerGame.Game.TurnNumber;

	automaticallyRandomlyPlayReconnaissanceCards(game, addNewOrder);
	wareOffActiveCards(game, addNewOrder);
end

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if type(game.Settings.Cards) ~= 'table' then
		return;
	end

	turnNum = game.ServerGame.Game.TurnNumber;

	local wz = {game = game, order = order, result = result, skipThisOrder = skipThisOrder, addNewOrder = addNewOrder};

	if order.proxyType == 'GameOrderPlayCardCustom' then
		parseGameOrderPlayCardCustom(wz);
	elseif order.proxyType == 'GameOrderCustom' then
		parseGameOrderCustom(wz);
	else
		preventReconnaissanceCardDiscardsIfRandomAutoplay(wz);
		doImmobilizeCardAffect(wz);
		prepDoTrapCardAffect(wz);
	end
end

function wareOffActiveCards(game, addNewOrder)
	if not Mod.PrivateGameData.ActiveCards then
		return;
	end

	local privateGD = Mod.PrivateGameData;
	local cardsThatCanWareOff = {
		'Reconnaissance+ Card',
		'Immobilize Card',
		'Trap Card'
	};

	for _, cardName in ipairs(cardsThatCanWareOff) do
		local card = getCardFromCardName(game, cardName);

		if card and privateGD.ActiveCards[card.Name] then
			local duration = (card.ActiveOrderDuration and card.ActiveOrderDuration) or 1;

			if duration <= 0 then
				duration = 1;
			end

			local turnCardPlayedOn = turnNum - duration;
			local cardsPlayed = privateGD.ActiveCards[card.Name][turnCardPlayedOn] or {};

			for key in pairs(cardsPlayed) do
				_G[sanitizeCardName(card.Name) .. 'WoreOff'](game, addNewOrder, card, cardsPlayed[key]);
			end

			privateGD.ActiveCards[card.Name][turnCardPlayedOn] = nil;
		end
	end

	Mod.PrivateGameData = privateGD;
end

function parseGameOrderPlayCardCustom(wz)
	local card = wz.game.Settings.Cards[wz.order.CardID];

	if not Mod.Settings[card.Name .. 'sEnabled'] then
		return;
	end

	local actualID = getSetting(card.Name .. 'ID');

	if not (actualID and actualID == card.CardID) then
		return;
	end

	-- game order custom used to make sure that card play getting skipped
	-- does not apply card being played in mod storage when card not played
	-- uses uuid to make sure another mod or unexpected game order custom does not interfere 

	local privateGD = Mod.PrivateGameData;
	local id = uuid();

	privateGD.ExpectedGameOrderCustom = {
		gocUUID = id,
		fnName = sanitizeCardName(card.Name) .. 'Played',
		CardID = card.ID,
		CardInstanceID = wz.order.CardInstanceID,
		ModData = wz.order.ModData,
		PlayerID = wz.order.PlayerID
	};

	Mod.PrivateGameData = privateGD;

	wz.addNewOrder(
		WL.GameOrderCustom.Create(
			wz.order.PlayerID,
			'Custom Card Package 2 functionality',
			'CCP2_' .. id
		),
		true
	);
end

function parseGameOrderCustom(wz)
	local payload = wz.order.Payload;

	if not payload:match('^CCP2_') then
		return;
	end;

	local gocUUID = payload:gsub('^CCP2_', '');
	local order = Mod.PrivateGameData.ExpectedGameOrderCustom;

	if type(order) ~= 'table' then
		return;
	end

	if gocUUID ~= order.gocUUID then
		return;
	end

	wz.order = order;

	local card = wz.game.Settings.Cards[order.CardID];

	print('about to call _G["' .. order.fnName .. '"](wz, card)');
	_G[order.fnName](wz, card);
	print('exited _G["' .. order.fnName .. '"](wz, card)');

	local privateGD = Mod.PrivateGameData;

	privateGD.ExpectedGameOrderCustom = nil;
	Mod.PrivateGameData = privateGD;
end

function getCardFromCardName(game, cardName)
	local cardId = getSetting(cardName .. 'sEnabled') and getSetting(cardName .. 'ID');

	if not cardId then
		return;
	end

	return game.Settings.Cards[cardId];
end

function getCardInstanceFromCardInstanceID(game, cardInstanceID)
	local cards = game.ServerGame.LatestTurnStanding.Cards;

	for playerId, playerCards in pairs(cards) do
		for cardInstanceId, cardInstance in pairs(playerCards.WholeCards) do
			if cardInstanceId == cardInstanceID then
				return cardInstance;
			end
		end
	end

	print('getCardInstanceFromCardInstanceID called')
	print('cardInstanceId not found in player cards');
	print('this should never happend');
end

function getTeammates(game, playerId)
	if playerId == WL.PlayerID.Neutral then
		return nil;
	end

	local players = game.ServerGame.Game.Players;
	local player = players[playerId];

	if player.Team == -1 then
		return {playerId};
	end

	-- if player is on a team, need to compare team with all other players
	-- remember the result of player team comparisons

	local publicGD = Mod.PublicGameData;

	if not publicGD.teams then
		publicGD.Teams = {};

		for player2Id, player2 in pairs(players) do
			if player2.Team > -1 then
				if not publicGD.Teams[player2.Team] then
					publicGD.Teams[player2.Team] = {};
				end

				table.insert(publicGD.Teams[player2.Team], player2Id);
			end
		end

		Mod.PublicGameData = publicGD;
	end

	return publicGD.Teams[player.Team];
end

function makeCouldNotPlayCardEvent(wz, card, reason)
	return WL.GameOrderEvent.Create(wz.order.PlayerID, 'Could not play ' .. aAn(card.Name, true) .. ' because ' .. reason, {});
end

function jumpToActionSpot(terrDetails)
	local x = terrDetails.MiddlePointX;
	local y = terrDetails.MiddlePointY;

	return WL.RectangleVM.Create(x, y, x, y);
end

function removeNonNeutralSpecailUnits(terrStanding, card)
	local commanderOwnersArr = {};
	local commanderOwnersMap = {};
	local specialUnitsToRemoveMap = {};
	local specialUnitsToRemoveArr = {};

	for _, specialUnit in pairs(terrStanding.NumArmies.SpecialUnits) do
		local specialUnitOwnerId = specialUnit.OwnerID;

		if specialUnitOwnerId ~= WL.PlayerID.Neutral then
			if not specialUnitsToRemoveMap[specialUnitOwnerId] then
				specialUnitsToRemoveMap[specialUnitOwnerId] = {};
			end

			if specialUnit.proxyType == 'Commander' and getSetting(card.Name .. 'EliminateIfCommander') then
				if not commanderOwnersMap[specialUnitOwnerId] then
					commanderOwnersMap[specialUnitOwnerId] = true;
					table.insert(commanderOwnersArr, specialUnitOwnerId);
				end
			end

			table.insert(specialUnitsToRemoveMap[specialUnitOwnerId], specialUnit.ID);
		end
	end

	for playerId in pairs(specialUnitsToRemoveMap) do
		-- no need to remove special units of players who are being eliminated anyway
		-- might cause an error if removing special unit that doesnt exist

		if not commanderOwnersMap[playerId] then
			for _, id in pairs(specialUnitsToRemoveMap[playerId]) do
				table.insert(specialUnitsToRemoveArr, id);
			end
		end
	end

	return {
		commanderOwnersArr = commanderOwnersArr,
		specialUnitsToRemoveArr = specialUnitsToRemoveArr
	};
end

function getRandomTerritory(game)
	if type(Mod.PublicGameData.TerrIdArray) ~= 'table' then
		local publicGD = Mod.PublicGameData;

		publicGD.TerrIdArray = {};

		for terrId in pairs(game.Map.Territories) do
			table.insert(publicGD.TerrIdArray, terrId);
		end

		Mod.PublicGameData = publicGD;
	end

	local rand = Mod.PublicGameData.TerrIdArray[math.random(1, #Mod.PublicGameData.TerrIdArray)];

	return game.Map.Territories[rand];
end

function automaticallyRandomlyPlayReconnaissanceCards(game, addNewOrder)
	local card = getCardFromCardName(game, 'Reconnaissance+ Card');

	if not (card and getSetting(card.Name .. 'RandomAutoplay')) then
		return;
	end

	local cards = game.ServerGame.LatestTurnStanding.Cards;

	for playerId, playerCards in pairs(cards) do
		for cardInstanceId, cardInstance in pairs(playerCards.WholeCards) do
			if cardInstance.CardID == card.CardID then
				local terr = getRandomTerritory(game);
				print('terr', terr);

				local wz = {
					game = game,
					addNewOrder = addNewOrder,
					order = {
						PlayerID = WL.PlayerID.Neutral,
						CardInstanceID = cardInstanceId,
						ModData = tostring(terr.ID)
					},
					cardOwner = playerId
				};

				ReconnaissanceCardPlayed(wz, card);
			end
		end
	end
end

function preventReconnaissanceCardDiscardsIfRandomAutoplay(wz)
	if wz.order.proxyType ~= 'GameOrderDiscard' then
		return;
	end

	local card = getCardFromCardName(wz.game, 'Reconnaissance+ Card');

	if not (card and getSetting(card.Name .. 'RandomAutoplay')) then
		return;
	end

	-- unable to card card instance from card instance id
	-- if it's a discard card order using the card instance id
	-- https://www.warzone.com/Forum/817723-mods-associate-cardinstanceid-playercards

	--[[
	local cardInstance = getCardInstanceFromCardInstanceID(wz.game, wz.order.CardInstanceID);

	if cardInstance.CardID ~= card.CardID then
		return;
	end

	wz.skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
	]]
end

function ReconnaissanceCardPlayed(wz, card)
	local isRandomAutoplay = getSetting(card.Name .. 'RandomAutoplay');

	if wz.order.PlayerID ~= WL.PlayerID.Neutral and isRandomAutoplay then
		-- the game handles this case by saying the play card order was skipped because you no longer have the card
		-- but this is for extra security
		wz.skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);

		return;
	end

	local terrId = tonumber(wz.order.ModData);
	local terrDetails = wz.game.Map.Territories[terrId];
	local range = getSetting(card.Name .. 'Range');
	local doneTerrs = {};
	local terrs = {};
	local privateGD = Mod.PrivateGameData;

	function addTerr(currentTerr, distance)
		if distance > range then
			return;
		end

		if doneTerrs[currentTerr.ID] then
			return;
		end

		table.insert(terrs, currentTerr.ID);
		doneTerrs[currentTerr.ID] = true;

		for terrId in pairs(currentTerr.ConnectedTo) do
			local nextTerr = wz.game.Map.Territories[terrId];

			addTerr(nextTerr, distance + 1);
		end
	end

	addTerr(terrDetails, 0);

	local fogMod = WL.FogMod.Create(
		card.Name .. ' played on ' .. terrDetails.Name,
		WL.StandingFogLevel.Visible,
		500,
		terrs,
		getTeammates(wz.game, wz.order.PlayerID)
		-- getTeammates(...) can return nil because of neutral player id
		-- nil means always players can see
		-- if neutral played, all players should see
	);

	if not privateGD.ActiveCards then
		privateGD.ActiveCards = {};
	end

	if not privateGD.ActiveCards[card.Name] then
		privateGD.ActiveCards[card.Name] = {};
	end

	if not privateGD.ActiveCards[card.Name][turnNum] then
		privateGD.ActiveCards[card.Name][turnNum] = {};
	end

	table.insert(privateGD.ActiveCards[card.Name][turnNum], {
		CardInstanceID = wz.order.CardInstanceID,
		PlayerID = wz.order.PlayerID,
		terrId = terrId,
		fogModId = fogMod.ID
	});

	Mod.PrivateGameData = privateGD;

	-- if neutral used for this event, all players can see
	local event = WL.GameOrderEvent.Create(wz.order.PlayerID, 'Played ' .. aAn(card.Name, true) .. ' on ' .. terrDetails.Name, {});

	event.JumpToActionSpotOpt = jumpToActionSpot(terrDetails);
	event.FogModsOpt = {fogMod};

	if isRandomAutoplay then
		event.RemoveWholeCardsOpt = {
			[wz.cardOwner] = wz.order.CardInstanceID
		};
	end

	wz.addNewOrder(event, true);
end

function ReconnaissanceCardWoreOff(game, addNewOrder, card, playedCard)
	local terrDetails = game.Map.Territories[playedCard.terrId];
	local event = WL.GameOrderEvent.Create(playedCard.PlayerID, card.Name .. ' wore off', {});

	event.JumpToActionSpotOpt = jumpToActionSpot(terrDetails);
	event.RemoveFogModsOpt = {playedCard.fogModId};

	addNewOrder(event);
end

function RecycleCardPlayed(wz, card)
	function removeSpecialUnits(terrStanding)
		local removeSpecialUnitsOpt = {};
		local totalSpecialUnitValue = 0;
		local unitValuesStr = '';
		local commanderOwners = {
			indexedByPlayerId = {},
			list = {}
		};

		for _, unit in pairs(terrStanding.NumArmies.SpecialUnits) do
			table.insert(removeSpecialUnitsOpt , unit.ID);

			local unitValue = 0

			unitValuesStr = unitValuesStr .. '\n';

			if unit.proxyType == 'CustomSpecialUnit' then
				if unit.Health then
					unitValue = unit.Health;
				else
					unitValue = unit.DamageToKill;
				end

				unitValuesStr = unitValuesStr .. unit.Name;
			else
				if unit.proxyType == 'Commander' then
					unitValue = 7;

					if not commanderOwners.indexedByPlayerId[unit.OwnerID] then
						table.insert(commanderOwners.list, unit.OwnerID);
					end

					commanderOwners.indexedByPlayerId[unit.OwnerID] = true;
				elseif unit.proxyType == 'Boss1' or unit.proxyType == 'Boss4' then
					unitValue = unit.Health;
				elseif unit.proxyType == 'Boss2' or unit.proxyType == 'Boss3' then
					unitValue = unit.Power;
				end

				unitValuesStr = unitValuesStr .. unit.proxyType;
			end

			unitValuesStr = unitValuesStr .. ' = ' .. unitValue;
			totalSpecialUnitValue = totalSpecialUnitValue + unitValue;
		end

		return {
			removeSpecialUnitsOpt = removeSpecialUnitsOpt,
			totalSpecialUnitValue = totalSpecialUnitValue,
			unitValuesStr = unitValuesStr,
			commanderOwners = commanderOwners
		};
	end

	local terrId = tonumber(wz.order.ModData);
	local terrDetails = wz.game.Map.Territories[terrId];

	local terrStanding = wz.game.ServerGame.LatestTurnStanding.Territories[terrId];
	local terrStandingT0 = wz.game.ServerGame.TurnZeroStanding.Territories[terrId];

	if terrStanding.OwnerPlayerID ~= wz.order.PlayerID then
		local event = makeCouldNotPlayCardEvent(wz, card, terrDetails.Name .. ' does not belong to you');

		event.JumpToActionSpotOpt = jumpToActionSpot(terrDetails);
		wz.addNewOrder(event, true);

		return;
	end

	local currArmiesOnTerr = terrStanding.NumArmies.NumArmies;
	local firstArmiesOnTerr = terrStandingT0.NumArmies.NumArmies;
	local armiesToAdd = -(currArmiesOnTerr - firstArmiesOnTerr);

	local terrMod = WL.TerritoryModification.Create(terrId);
	local incomeModMsg = 'Value of armies that were on ' .. terrDetails.Name;
	local spRemovalData = removeSpecialUnits(terrStanding);

	terrMod.SetOwnerOpt = WL.PlayerID.Neutral;
	terrMod.AddArmies = armiesToAdd;
	terrMod.RemoveSpecialUnitsOpt = spRemovalData.removeSpecialUnitsOpt;

	if spRemovalData.totalSpecialUnitValue > 0 then
		incomeModMsg = incomeModMsg .. '\nArmies = ' .. currArmiesOnTerr .. '\nSpecial units = ' .. spRemovalData.totalSpecialUnitValue .. spRemovalData.unitValuesStr;
	end

	local incomeModPlayerID = wz.order.PlayerID;
	local eliminatingSelf = spRemovalData.commanderOwners.indexedByPlayerId[wz.order.PlayerID];

	local terrModsOpt;

	if getSetting(card.Name .. 'EliminateIfCommander') then
		local toEliminate = spRemovalData.commanderOwners.list;

		terrModsOpt = eliminate(toEliminate, wz.game.ServerGame.LatestTurnStanding.Territories, true, wz.game.Settings.SinglePlayer);
	end

	if not terrModsOpt then
		terrModsOpt = {};
	end

	table.insert(terrModsOpt, terrMod);

	-- if target player for income mod is eliminated, income mod isnt applied
	-- this case is handled by the game itself

	local incomeModsOpt = {WL.IncomeMod.Create(wz.order.PlayerID, currArmiesOnTerr + spRemovalData.totalSpecialUnitValue, incomeModMsg)};
	local event = WL.GameOrderEvent.Create(wz.order.PlayerID, 'Played ' .. aAn(card.Name, true) .. ' on ' .. terrDetails.Name .. addDuration(card), {}, terrModsOpt, nil, incomeModsOpt);

	event.JumpToActionSpotOpt = jumpToActionSpot(terrDetails);

	wz.addNewOrder(event, true);
end

function ImmobilizeCardPlayed(wz, card)
	local terrId = tonumber(wz.order.ModData);
	local terrDetails = wz.game.Map.Territories[terrId];
	local terrStanding = wz.game.ServerGame.LatestTurnStanding.Territories[terrId];

	if terrStanding.OwnerPlayerID ~= wz.order.PlayerID then
		local connectedTerrOwnByCardPlayer = false;

		for connTerrId in pairs(terrDetails.ConnectedTo) do
			local connTerr = wz.game.ServerGame.LatestTurnStanding.Territories[connTerrId];
			connectedTerrOwnByCardPlayer = connTerr.OwnerPlayerID == wz.order.PlayerID;

			if connectedTerrOwnByCardPlayer then
				break;
			end
		end

		if not connectedTerrOwnByCardPlayer then
			local event = makeCouldNotPlayCardEvent(wz, card, terrDetails.Name .. ' is not one of your own territories or connect to your territories');

			event.JumpToActionSpotOpt = jumpToActionSpot(terrDetails);
			wz.addNewOrder(event, true);

			return;
		end
	end

	local playerGD = Mod.PlayerGameData;
	local privateGD = Mod.PrivateGameData;
	local teammates = getTeammates(wz.game, wz.order.PlayerID) or {};
	local turnCardWaresOffOn = turnNum + card.ActiveOrderDuration;

	-- for client-side order validation, prevent useless orders

	for _, playerId in pairs(teammates) do
		if not playerGD[playerId] then
			playerGD[playerId] = {};
		end

		if not playerGD[playerId].KnownActiveCards then
			playerGD[playerId].KnownActiveCards = {};
		end

		if not playerGD[playerId].KnownActiveCards[card.Name] then
			playerGD[playerId].KnownActiveCards[card.Name] = {};
		end

		playerGD[playerId].KnownActiveCards[card.Name][terrDetails.ID] = turnCardWaresOffOn;
	end

	if not privateGD.ActiveCards then
		privateGD.ActiveCards = {};
	end

	if not privateGD.ActiveCards[card.Name] then
		privateGD.ActiveCards[card.Name] = {};
	end

	if not privateGD.ActiveCards[card.Name][turnNum] then
		privateGD.ActiveCards[card.Name][turnNum] = {};
	end

	if not privateGD.ActiveCards[card.Name][turnNum][terrDetails.ID] then
		privateGD.ActiveCards[card.Name][turnNum][terrDetails.ID] = {}
	end

	table.insert(privateGD.ActiveCards[card.Name][turnNum][terrDetails.ID], {
		CardInstanceID = wz.order.CardInstanceID,
		PlayerID = wz.order.PlayerID,
		terrId = terrDetails.ID
	});

	Mod.PlayerGameData = playerGD;
	Mod.PrivateGameData = privateGD;

	local event = WL.GameOrderEvent.Create(wz.order.PlayerID, 'Played ' .. aAn(card.Name, true) .. ' on ' .. terrDetails.Name .. addDuration(card), {});

	event.JumpToActionSpotOpt = jumpToActionSpot(terrDetails);
	wz.addNewOrder(event, nil);
end

function doImmobilizeCardAffect(wz)
	local card = getCardFromCardName(wz.game, 'Immobilize Card');

	if not card then
		return;
	end

	local isAttackTransfer = wz.order.proxyType == 'GameOrderAttackTransfer';
	local isAirlift = wz.order.proxyType == 'GameOrderPlayCardAirlift';

	if not (isAttackTransfer or isAirlift) then
		return;
	end

	local toTerrKey = 'To';
	local fromTerrKey = 'From';
	local movementType;

	if isAttackTransfer then
		movementType = 'attack/transfer';
	else
		movementType = 'airlift';
		toTerrKey = toTerrKey .. 'TerritoryID';
		fromTerrKey = fromTerrKey .. 'TerritoryID';
	end

	local toTerrDetails = wz.game.Map.Territories[wz.order[toTerrKey]];
	local fromTerrDetails = wz.game.Map.Territories[wz.order[fromTerrKey]];

	if not Mod.PrivateGameData.ActiveCards then
		return;
	end

	if not Mod.PrivateGameData.ActiveCards[card.Name] then
		return;
	end

	local map = Mod.PrivateGameData.ActiveCards[card.Name][turnNum];

	if not map then
		return;
	end

	local affectedTerr = (map[toTerrDetails.ID] and toTerrDetails) or (map[fromTerrDetails.ID] and fromTerrDetails);

	if not affectedTerr then
		return;
	end

	wz.skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);

	local msg = 'Skipped ' .. movementType .. ' to ' .. toTerrDetails.Name .. ' from ' .. fromTerrDetails.Name .. ' because ' .. aAn(card.Name, true) .. ' was played on ' .. affectedTerr.Name;
	local event = WL.GameOrderEvent.Create(wz.order.PlayerID, msg, {}, {WL.TerritoryModification.Create(affectedTerr.ID)});

	event.JumpToActionSpotOpt = jumpToActionSpot(affectedTerr);
	wz.addNewOrder(event);
end

function ImmobilizeCardWoreOff(game, addNewOrder, card, turnData)
	for _, playedCard in pairs(turnData) do
		local terrDetails = game.Map.Territories[playedCard.terrId];

		local playerGD = Mod.PlayerGameData;
		local teammates = getTeammates(game, playedCard.PlayerID) or {};

		for _, playerId in ipairs(teammates) do
			if (
				playerGD[playerId] and
				playerGD[playerId].KnownActiveCards and
				playerGD[playerId].KnownActiveCards[card.Name]
			) then
				local wareOffTurn = playerGD[playerId].KnownActiveCards[card.Name][terrDetails.ID] or 0;

				if turnNum <= wareOffTurn then
					playerGD[playerId].KnownActiveCards[card.Name][terrDetails.ID] = nil;
				end
			end
		end

		Mod.PlayerGameData = playerGD;
	end
end

function TrapCardPlayed(wz, card)
	local terrId = tonumber(wz.order.ModData);
	local terrDetails = wz.game.Map.Territories[terrId];
	local terrStanding = wz.game.ServerGame.LatestTurnStanding.Territories[terrId];

	if terrStanding.OwnerPlayerID ~= wz.order.PlayerID then
		local event = makeCouldNotPlayCardEvent(wz, card, terrDetails.Name .. ' does not belong to you');

		event.JumpToActionSpotOpt = jumpToActionSpot(terrDetails);
		wz.addNewOrder(event, true);

		return;
	end

	local privateGD = Mod.PrivateGameData;

	if not privateGD.ActiveCards then
		privateGD.ActiveCards = {};
	end

	if not privateGD.ActiveCards[card.Name] then
		privateGD.ActiveCards[card.Name] = {};
	end

	if not privateGD.ActiveCards[card.Name][turnNum] then
		privateGD.ActiveCards[card.Name][turnNum] = {};
	end

	if not privateGD.ActiveCards[card.Name][turnNum][terrDetails.ID] then
		privateGD.ActiveCards[card.Name][turnNum][terrDetails.ID] = {};
	end

	table.insert(privateGD.ActiveCards[card.Name][turnNum][terrDetails.ID], {
		CardInstanceID = wz.order.CardInstanceID,
		PlayerID = wz.order.PlayerID,
		terrId = terrDetails.ID,
		turnNum = turnNum
	});

	Mod.PrivateGameData = privateGD;

	local event = WL.GameOrderEvent.Create(wz.order.PlayerID, 'Played ' .. aAn(card.Name, true) .. ' on ' .. terrDetails.Name, {});

	event.JumpToActionSpotOpt = jumpToActionSpot(terrDetails);
	wz.addNewOrder(event, true);
end

function prepDoTrapCardAffect(wz)
	local isAttackTransfer = wz.order.proxyType == 'GameOrderAttackTransfer';

	if not isAttackTransfer then
		return;
	end

	local card = getCardFromCardName(wz.game, 'Trap Card');

	if not card then
		return;
	end

	local toTerrDetails = wz.game.Map.Territories[wz.order.To];

	if not (
		Mod.PrivateGameData.ActiveCards and
		Mod.PrivateGameData.ActiveCards[card.Name] and
		Mod.PrivateGameData.ActiveCards[card.Name][turnNum] and
		Mod.PrivateGameData.ActiveCards[card.Name][turnNum][toTerrDetails.ID]
	) then
		return;
	end

	local attacker = wz.game.ServerGame.Game.PlayingPlayers[wz.order.PlayerID];
	local attackerIsFriendly = true;

	for _, playedCard in ipairs(Mod.PrivateGameData.ActiveCards[card.Name][turnNum][toTerrDetails.ID]) do
		-- ordering of cards doesnt matter, only the original territory owner can play cards on the territory
		-- ipairs is only for efficiency

		local cardPlayer = wz.game.ServerGame.Game.Players[playedCard.PlayerID];

		-- NOTE if the card player is no longer playing
		-- all their cards still active, until they expire normally
		-- and that when orders are created, the order will not go ahead

		if (
			cardPlayer.Team == -1 or
			((cardPlayer.Team ~= -1) and cardPlayer.Team ~= attacker.Team)
		) then
			attackerIsFriendly = false;
			break;
		end
	end

	if attackerIsFriendly then
		return;
	end

	-- game order custom used to make sure that card affect happens on its own game standing
	-- uses uuid to make sure another mod or unexpected game order custom does not interfere

	local privateGD = Mod.PrivateGameData;
	local id = uuid();

	privateGD.ExpectedGameOrderCustom = {
		gocUUID = id,
		fnName = 'Do' .. sanitizeCardName(card.Name) .. 'Affect',
		terrId = toTerrDetails.ID,
		playedCardIndex = playedCardIndex,
		CardID = card.ID
	};

	Mod.PrivateGameData = privateGD;

	wz.addNewOrder(
		WL.GameOrderCustom.Create(
			wz.order.PlayerID,
			'Custom Card Package 2 functionality',
			'CCP2_' .. id
		),
		true
	);
end

function DoTrapCardAffect(wz, card)
	local privateGD = Mod.PrivateGameData;
	local terrDetails = wz.game.Map.Territories[privateGD.ExpectedGameOrderCustom.terrId];
	local territoriesStanding = wz.game.ServerGame.LatestTurnStanding.Territories;
	local terrStanding = territoriesStanding[terrDetails.ID];

	if terrStanding.OwnerPlayerID == WL.PlayerID.Neutral then
		-- a mod changed the territory neutral
		-- so dont multiply armies because it wasnt captured by a player

		return;
	end

	-- ordering of playedCards doesnt matter, safe to use any index
	-- as long as index is in range

	local playedCard = privateGD.ActiveCards[card.Name][turnNum][terrDetails.ID][1];
	local terrOwner = wz.game.ServerGame.Game.PlayingPlayers[terrStanding.OwnerPlayerID];
	local cardPlayer = wz.game.ServerGame.Game.Players[playedCard.PlayerID];

	if cardPlayer.Team > -1 and (cardPlayer.Team == terrOwner.Team) then
		return;
	end

	if playedCard.PlayerID == terrStanding.OwnerPlayerID then
		-- not using terrOwner.PlayerID or cardPlayer.PlayerID because
		-- GamePlayer.PlayerID is nil for AI players

		return;
	end

	table.remove(privateGD.ActiveCards[card.Name][turnNum][terrDetails.ID]);
	Mod.PrivateGameData = privateGD;

	local specailUnitRemovalData = removeNonNeutralSpecailUnits(terrStanding, card);
	local commanderOwnersArr = specailUnitRemovalData.commanderOwnersArr;
	local specialUnitsToRemoveArr = specailUnitRemovalData.specialUnitsToRemoveArr;

	local terrMods = {};

	if #commanderOwnersArr > 0 then
		terrMods = eliminate(commanderOwnersArr, territoriesStanding, true, wz.game.Settings.SinglePlayer);
	end

	local terrMod = WL.TerritoryModification.Create(terrDetails.ID);
	local armies = terrStanding.NumArmies.NumArmies;

	terrMod.SetOwnerOpt = WL.PlayerID.Neutral;
	terrMod.AddArmies = round(armies * getSetting(card.Name .. 'Multiplier')) - armies;
	terrMod.RemoveSpecialUnitsOpt = specialUnitsToRemoveArr;

	table.insert(terrMods, terrMod);

	-- see NOTE in prepDoTrapCardAffect
	local event = WL.GameOrderEvent.Create(playedCard.PlayerID, card.Name .. ' activated', {}, terrMods);

	event.JumpToActionSpotOpt = jumpToActionSpot(terrDetails);

	wz.addNewOrder(event, true);
end

function TrapCardWoreOff(game, addNewOrder, card, turnData)
	-- this function just needs to be defined

	-- below can be used for if custom duration is added
	--[[
	for _, playedCard in pairs(turnData) do
		local terrDetails = game.Map.Territories[playedCard.terrId];
		local event = WL.GameOrderEvent.Create(playedCard.PlayerID, card.Name .. ' wore off', {});

		event.JumpToActionSpotOpt = jumpToActionSpot(terrDetails);

		addNewOrder(event);
	end
	]]
end

function RushedBlockadeCardPlayed(wz, card)
	local terrId = tonumber(wz.order.ModData);
	local terrDetails = wz.game.Map.Territories[terrId];
	local terrStanding = wz.game.ServerGame.LatestTurnStanding.Territories[terrId];

	if terrStanding.OwnerPlayerID ~= wz.order.PlayerID then
		local event = makeCouldNotPlayCardEvent(wz, card, terrDetails.Name .. ' does not belong to you');

		event.JumpToActionSpotOpt = jumpToActionSpot(terrDetails);
		wz.addNewOrder(event, true);

		return;
	end

	local specailUnitRemovalData = removeNonNeutralSpecailUnits(terrStanding, card);
	local commanderOwnersArr = specailUnitRemovalData.commanderOwnersArr;
	local specialUnitsToRemoveArr = specailUnitRemovalData.specialUnitsToRemoveArr;

	local terrMods = {};

	if #commanderOwnersArr > 0 then
		terrMods = eliminate(commanderOwnersArr, territoriesStanding, true, wz.game.Settings.SinglePlayer);
	end

	local terrMod = WL.TerritoryModification.Create(terrDetails.ID);
	local armies = terrStanding.NumArmies.NumArmies;

	terrMod.SetOwnerOpt = WL.PlayerID.Neutral;
	terrMod.AddArmies = round(armies * getSetting(card.Name .. 'Multiplier')) - armies;
	terrMod.RemoveSpecialUnitsOpt = specialUnitsToRemoveArr;

	table.insert(terrMods, terrMod);

	local event = WL.GameOrderEvent.Create(wz.order.PlayerID, 'Played ' .. aAn(card.Name, true) .. ' on ' .. terrDetails.Name, {}, terrMods);

	event.JumpToActionSpotOpt = jumpToActionSpot(terrDetails);

	wz.addNewOrder(event, true);
end