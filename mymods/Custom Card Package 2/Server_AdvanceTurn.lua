require 'version';
require '_settings';
require '_util';
require 'cards';

local playersWithSuccessfulAttacks = {};

function Server_AdvanceTurn_Start(game, addNewOrder)
	for playerId in pairs(game.ServerGame.Game.PlayingPlayers) do
		playersWithSuccessfulAttacks[playerId] = false;
	end

	if not Mod.PublicGameData.activeCards then
		return;
	end

	for cardName in pairs(Mod.PublicGameData.activeCards) do
		_G['processStartTurn' .. cardName](game, addNewOrder, cardName);
	end
end

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	local wz = {
		game = game,
		order = order,
		result = result,
		addNewOrder = addNewOrder,
		skipThisOrder = skipThisOrder
	};

	processGameOrderCustom(wz);

	if Mod.PublicGameData.activeCards and order.proxyType ~= 'GameOrderCustom' and order.proxyType ~= 'GameOrderEvent' then
		for cardName, enabled in pairs(Mod.PublicGameData.cardsThatCanBeActive) do
			if enabled then
				_G['processOrder' .. cardName](wz, cardName);
			end
		end
	end

	processGameOrderAttackTransfer(wz);
end

function Server_AdvanceTurn_End(game, addNewOrder)
	local earnedPieces = {};

	for _, cardName in pairs(Mod.PublicGameData.cardNames) do
		local enabled = getSetting('Enable' .. cardName);
		local numPieces = getSetting(cardName .. 'PiecesPerTurn');
		local needsAttack = getSetting(cardName .. 'NeedsSuccessfulAttackToEarnPiece');

		if enabled and numPieces and numPieces ~= 0 then
			if needsAttack then
				for playerId, hadSuccessfulAttack in pairs(playersWithSuccessfulAttacks) do
					local player = game.ServerGame.Game.Players[playerId];

					if player.State == WL.GamePlayerState.Playing and hadSuccessfulAttack then
						if not earnedPieces[playerId] then
							earnedPieces[playerId] = {};
						end

						earnedPieces[playerId][cardName] = numPieces;
					end
				end
			else
				for playerId in pairs(game.ServerGame.Game.PlayingPlayers) do
					if not earnedPieces[playerId] then
						earnedPieces[playerId] = {};
					end

					earnedPieces[playerId][cardName] = numPieces;
				end
			end
		end
	end

	for playerId in pairs(earnedPieces) do
		local msgPrefix = game.ServerGame.Game.PlayingPlayers[playerId].DisplayName(nil, false) .. ' received ';
		local payloadPrefix = 'CCP2_addCardPieces_' .. playerId .. '_<';

		for cardName, numPieces in pairs(earnedPieces[playerId]) do
			local msg = msgPrefix .. numPieces .. ' piece' .. (numPieces > 1 and 's' or '') .. ' of a ' .. cardName .. ' Card';
			local payload = payloadPrefix .. cardName .. '=[' .. numPieces .. ']>';
			local order = WL.GameOrderCustom.Create(playerId, msg, payload);

			addNewOrder(order);
		end
	end
end

function processGameOrderCustom(wz)
	if not (wz.order.proxyType == 'GameOrderCustom' and startsWith(wz.order.Payload, 'CCP2_')) then
		return;
	end

	if wz.game.Settings.SinglePlayer and not canRunMod() then
		return;
	end

	parseGameOrderCustom(wz);
end

function parseGameOrderCustom(wz)
	-- https://www.lua.org/pil/20.2.html
	-- 'CCP2_addCardPieces_1000_<Reconnaissance+=[1],Reconnaissance+=[-1]>'
	-- 'CCP2_useCard_1000_<Reconnaissance+=[100],Reconnaissance+=[]>'
	-- 'CCP2_buyCard_1000_<Reconnaissance+=[],Reconnaissance+=[]>'

	local _, _, command, playerId, cards = string.find(wz.order.Payload, '^CCP2_([^_]+)_(%d+)_<([^>]+)>$');
	playerId = round(tonumber(playerId));

	if playerId and wz.game.ServerGame.Game.PlayingPlayers[playerId] and command and cards and _G[command] then
		local player = wz.game.ServerGame.Game.PlayingPlayers[playerId];
		local commaSplit = split(cards, ',');

		for _, str2 in pairs(commaSplit) do
			local _, _, cardName, param = string.find(str2, '^([^=]+)=%[([^%]]*)%]$');

			if cardName and param and getSetting('Enable' .. cardName) then
				-- custom orders arent always displayed
				-- safe to skip valid ones and create unstoppable events that say what happened
				wz.skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);

				-- https://stackoverflow.com/questions/1791234/lua-call-function-from-a-string-with-function-name
				_G[command](wz, player, cardName, param);
			end
		end
	end
end

function addCardPieces(wz, player, cardName, param)
	local numPieces = round(tonumber(param));

	if numPieces == 0 then
		return;
	end

	local publicGD = Mod.PublicGameData;
	local teamType = player.Team == -1 and 'noTeam' or 'teammed';
	local teamId = player.Team == -1 and player.ID or player.Team;
	local result = publicGD.cardPieces[teamType][teamId].currentPieces[cardName] + numPieces;
	local resulting = result > -1 and result or 0;

	publicGD.cardPieces[teamType][teamId].currentPieces[cardName] = resulting;
	Mod.PublicGameData = publicGD;

	local playerGD = Mod.PlayerGameData;
	local members = player.Team == -1 and {teamId} or publicGD.teams[teamId].members;
	local shownReceivedCardsMsg = resulting < getSetting(cardName .. 'PiecesInCard');

	for _, playerId in pairs(members) do
		playerGD[playerId].shownReceivedCardsMsg = shownReceivedCardsMsg;
	end

	Mod.PlayerGameData = playerGD;

	local msgPrefix = player.DisplayName(nil, false) .. ' received ';
	local msg = msgPrefix .. numPieces .. ' piece' .. (numPieces ~= 1 and 's' or '') .. ' of a ' .. cardName .. ' Card';
	wz.addNewOrder(WL.GameOrderEvent.Create(player.ID, msg, {}));
end

function playedCard(wz, player, cardName, param)
	local fnName = 'playedCard' .. string.gsub(cardName, '[^%w_]', '');

	-- need to check if enough pieces to play card
	local piecesInCard = getSetting(cardName .. 'PiecesInCard');
	local publicGD = Mod.PublicGameData;
	local teamType = player.Team == -1 and 'noTeam' or 'teammed';
	local teamId = player.Team == -1 and player.ID or player.Team;

	if Mod.PublicGameData.cardPieces[teamType][teamId].currentPieces[cardName] < piecesInCard then
		return;
	end

	local success = _G[fnName](wz, player, cardName, param);
	if not success then
		return;
	end

	if publicGD.cardsThatCanBeActive[cardName] then
		if not publicGD.activeCards then
			publicGD.activeCards = {};
		end

		if not publicGD.activeCards[cardName] then
			publicGD.activeCards[cardName] = {};
		end

		table.insert(publicGD.activeCards[cardName], {
			playedBy = player.ID,
			playedOnTurn = wz.game.ServerGame.Game.TurnNumber,
			param = param
		});
	end

	-- reduce number of current pieces
	local result = publicGD.cardPieces[teamType][teamId].currentPieces[cardName] - piecesInCard;
	publicGD.cardPieces[teamType][teamId].currentPieces[cardName] = result > -1 and result or 0;
	Mod.PublicGameData = publicGD;
end

function playedTerritorySelectionCard(wz, player, cardName, param)
	local terrId = tonumber(param);
	local terr = wz.game.Map.Territories[terrId];

	if not terr then
		return;
	end

	local msg = 'Played a ' .. cardName .. ' Card on ' .. terr.Name;
	local visTo = {};

	if Mod.PublicGameData.cardsThatCanBeActive[cardName] then
		local duration = getSetting(cardName .. 'Duration');

		if duration then
			msg = msg .. ' for ' .. duration .. ' turns';
			visTo = nil;
		end
	end

	local event = WL.GameOrderEvent.Create(player.ID, msg, visTo);
	event.JumpToActionSpotOpt = WL.RectangleVM.Create(terr.MiddlePointX, terr.MiddlePointY, terr.MiddlePointX, terr.MiddlePointY);

	wz.addNewOrder(event);

	return true;
end

function buyCard(wz, player, cardName)
	local order = WL.GameOrderEvent.Create(player.ID, 'Bought a ' .. cardName .. ' Card', {});
	order.AddResourceOpt = {
		[player.ID] = {
			[WL.ResourceType.Gold] = -getSetting(cardName .. 'Cost');
		}
	};

	wz.addNewOrder(order);

	local piecesInCard = getSetting(cardName .. 'PiecesInCard');
	local publicGD = Mod.PublicGameData;
	local teamType = player.Team == -1 and 'noTeam' or 'teammed';
	local teamId = player.Team == -1 and player.ID or player.Team;

	publicGD.cardPieces[teamType][teamId].currentPieces[cardName] = publicGD.cardPieces[teamType][teamId].currentPieces[cardName] + piecesInCard;
	Mod.PublicGameData = publicGD;
end

function processGameOrderAttackTransfer(wz)
	if not wz.order or not wz.result then
		return;
	end

	if wz.order.proxyType ~= 'GameOrderAttackTransfer' or wz.order.PlayerID == WL.PlayerID.Neutral or playersWithSuccessfulAttacks[wz.order.PlayerID] then
		return;
	end

	if wz.result.IsAttack and wz.result.IsSuccessful then
		playersWithSuccessfulAttacks[wz.order.PlayerID] = true;
	end
end

function removeActiveCardInstance(cardName, i)
	local publicGD = Mod.PublicGameData;
	table.remove(publicGD.activeCards[cardName], i);

	if #publicGD.activeCards[cardName] < 1 then
		publicGD.activeCards[cardName] = nil;
	end

	for cardName in pairs(publicGD.cardsThatCanBeActive) do
		if publicGD.activeCards[cardName] then
			Mod.PublicGameData = publicGD;
			return;
		end
	end

	publicGD.activeCards = nil;
	Mod.PublicGameData = publicGD;
end

function removeAllActiveCardInstancesOf(cardName)
	local publicGD = Mod.PublicGameData;

	publicGD.activeCards[cardName] = nil;

	for cardName in pairs(publicGD.activeCards) do
		if publicGD[cardName] then
			Mod.PublicGameData = publicGD;
			return;
		end
	end

	publicGD.activeCards = nil;
	Mod.PublicGameData = publicGD;
end

function removeExpiredCardInstances(game, addNewOrder, cardName)
	local duration = getSetting(cardName .. 'Duration');
	local i = 1;

	while true do
		if not Mod.PublicGameData.activeCards or not Mod.PublicGameData.activeCards[cardName] then
			break;
		end

		local activeCardInstance = Mod.PublicGameData.activeCards[cardName][i];

		if not activeCardInstance then
			break;
		end

		if activeCardInstance.playedOnTurn + duration == game.ServerGame.Game.TurnNumber then
			local terr = game.Map.Territories[tonumber(activeCardInstance.param)];
			local msg = 'A ' .. cardName .. ' Card that was played on ' .. terr.Name .. ' during turn ' .. activeCardInstance.playedOnTurn .. ' wore off';
			local event = WL.GameOrderEvent.Create(activeCardInstance.playedBy, msg, nil);
			event.JumpToActionSpotOpt = WL.RectangleVM.Create(terr.MiddlePointX, terr.MiddlePointY, terr.MiddlePointX, terr.MiddlePointY);

			addNewOrder(event);
			removeActiveCardInstance(cardName, i);
			i = i - 1;
		end

		i = i + 1;
	end
end