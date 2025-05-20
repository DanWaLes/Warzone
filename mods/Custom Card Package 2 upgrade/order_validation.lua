local function MakeUnplayCardMsg(vert)
	local function label(msg, parent)
		return Label((parent and parent) or vert).SetText(msg);
	end

	local horz = Horz(vert);

	label('You can un-play cards', horz).SetColor('#23A0FF');
	label('by:', horz);
	label('1) Going into the Orders List');
	label('2) Clicking an order');
	label('3) Clicking the X button');
end

function SelectedTerrIsOwnTerr(game, terrId)
	-- called by _G in file Client_PresentPlayCardUI

	local terr = game.LatestStanding.Territories[terrId];

	return terr.OwnerPlayerID == game.Us.ID;
end

function SelectedTerrIsOwnTerrOrConnectedToOwnTerr(game, terrId)
	if SelectedTerrIsOwnTerr(game, terrId) then
		return true;
	end

	for connTerrId in pairs(game.Map.Territories[terrId].ConnectedTo) do
		if SelectedTerrIsOwnTerr(game, connTerrId) then
			return true;
		end
	end

	return false;
end

function OrderIsValidWhenImmobilizeCardIsActive(game, card, path, order, skipOrder)
	-- called by _G in file Client_GameOrderCreated

	local isAttackTransfer = order.proxyType == 'GameOrderAttackTransfer';
	local isAirlift = order.proxyType == 'GameOrderPlayCardAirlift';

	if not (isAttackTransfer or isAirlift) then
		return true;
	end

	local found = false;
	local affectedTerr;
	local details = {
		game.Map.Territories[order.To],
		game.Map.Territories[order.From]
	};

	for _, terrDetails in pairs(details) do
		if path[terrDetails.ID] and (path[terrDetails.ID] > game.Game.TurnNumber) then
			found = true;
			affectedTerr = terrDetails;
			break;
		end
	end

	if not found then
		return true;
	end

	skipOrder();

	game.CreateDialog(
		function(vert, setMaxSize, setScrollable)
			setMaxSize(480, 270) -- 16:9 on 30
			setScrollable(false, true);

			CustomCardHelpButton(card, Horz(vert), Vert(vert));

			Label(vert)
				.SetText('Order disallowed due to active ' .. card.Name .. ' (wares off at start of turn '.. path[affectedTerr.ID] .. ')')
				.SetColor('#FF0000');

			-- this fnName is a function name from this file
			local fnName = 'MakeOrderIsInvalidWhen' .. sanitizeCardName(card.Name) .. 'PlayedMsg';
			local fakeCardOrder = {
				ModData = tostring(affectedTerr.ID)
			};

			print('about to call _G[' .. fnName .. '](game, vert, card, fakeCardOrder, order, true, true)');
			_G[fnName](game, vert, card, fakeCardOrder, order, true, true);
			print('exited _G[' .. fnName .. '](game, vert, card, fakeCardOrder, order, true, true)');
		end
	);

	return false;
end

function OrderIsValidWhenReconnaissanceCardPlayed(game, card, cardOrder, order)
	-- called by _G in files Client_GameOrderCreated and Client_PresentPlayCardUI

	if order.proxyType == 'GameOrderPlayCardCustom' then
		return not (cardOrder.CardID == order.CardID and cardOrder.ModData == order.ModData);
	end

	return true;
end

function OrderIsValidWhenRecycleCardPlayed(game, card, cardOrder, order)
	-- called by _G in files Client_GameOrderCreated and Client_PresentPlayCardUI

	local terrId = tonumber(cardOrder.ModData);

	if order.proxyType == 'GameOrderPlayCardCustom' then
		return not (cardOrder.CardID == order.CardID and cardOrder.ModData == order.ModData);
	elseif order.proxyType == 'GameOrderDeploy' then
		return terrId ~= order.DeployOn;
	-- the below order types are useless
	-- unless a mod interferes with the territory
	-- after it becomes neutral and before the order happens
	elseif order.proxyType == 'GameOrderPlayCardAbandon' then
		return terrId ~= order.TargetTerritoryID;
	elseif order.proxyType == 'GameOrderPlayCardAirlift' then
		return terrId ~= order.FromTerritoryID;
	elseif order.proxyType == 'GameOrderPlayCardGift' then
		return terrId ~= order.TerritoryID;
	elseif order.proxyType == 'GameOrderAttackTransfer' then
		return terrId ~= order.From;
	end

	return true;
end

function OrderIsValidWhenImmobilizeCardPlayed(game, card, cardOrder, order)
	-- called by _G in files Client_GameOrderCreated and Client_PresentPlayCardUI

	local terrId = tonumber(cardOrder.ModData);

	if order.proxyType == 'GameOrderPlayCardCustom' then
		return not (cardOrder.CardID == order.CardID and cardOrder.ModData == order.ModData);
	elseif order.proxyType == 'GameOrderPlayCardAirlift' then
		return not (order.ToTerritoryID == terrId or order.FromTerritoryID == terrId);
	elseif order.proxyType == 'GameOrderAttackTransfer' then
		return not (order.To == terrId or order.From == terrId);
	end

	return true;
end

function OrderIsValidWhenTrapCardPlayed(game, card, cardOrder, order)
	-- called by _G in file Client_GameOrderCreated

	return true;
end

function OrderIsValidWhenRushedBlockadeCardPlayed(game, card, cardOrder, order)
	-- called by _G in file Client_GameOrderCreated

	return true;
end

function MakeOrderIsInvalidWhenReconnaissanceCardPlayedMsg(game, parent, card, cardOrder, order, newOrderIsOrder)
	-- called by _G in files Client_GameOrderCreated and Client_PresentPlayCardUI

	local color = (newOrderIsOrder and '#FF7D00') or '#FF0000';
	local horz = Horz(parent);

	function label(txt)
		return Label(horz).SetText(txt).SetColor(color);
	end

	HighlightTerrBtn(game, tonumber(cardOrder.ModData), horz);

	if order.proxyType == 'GameOrderPlayCardCustom' then
		return label('already has a ' .. card.Name .. ' played on it');
	end
end

function MakeOrderIsInvalidWhenRecycleCardPlayedMsg(game, parent, card, cardOrder, order, newOrderIsOrder)
	-- called by _G in files Client_GameOrderCreated and Client_PresentPlayCardUI

	local color = (newOrderIsOrder and '#FF7D00') or '#FF0000';
	local horz = Horz(parent);

	function label(txt)
		return Label(horz).SetText(txt).SetColor(color);
	end

	HighlightTerrBtn(game, tonumber(cardOrder.ModData), horz);

	if order.proxyType == 'GameOrderPlayCardCustom' then
		return label('already has a ' .. card.Name .. ' played on it');
	end

	if order.proxyType == 'GameOrderDeploy' then
		return label('deployments would get added back into your income');
	end

	if newOrderIsOrder then
		label('would no longer be yours after the ' .. card.Name .. ' is played, making the order you tried to do useless');
		MakeUnplayCardMsg(parent);

		return;
	end

	local useless = ' from here would become useless if the ' .. card.Name .. ' is played. ';
	local retry = ' then try again, or select a different territory.';

	if order.proxyType == 'GameOrderAttackTransfer' then
		return label('attacks/transfers' .. useless .. 'Remove attacks/transfers from here' .. retry);
	end

	if order.proxyType == 'GameOrderPlayCardAbandon' then
		label('Emergence Blockade Cards' .. useless .. 'Un-play the card' .. retry);
	elseif order.proxyType == 'GameOrderPlayCardAirlift' then
		label('Airlift Cards' .. useless ..  'Un-play the card' .. retry);
	elseif order.proxyType == 'GameOrderPlayCardGift' then
		label('Gift Cards' .. useless ..  'Un-play the card' .. retry);
	end

	MakeUnplayCardMsg(parent);
end

function MakeOrderIsInvalidWhenImmobilizeCardPlayedMsg(game, parent, card, cardOrder, order, newOrderIsOrder, isActiveCard)
	-- called by _G in files Client_GameOrderCreated and Client_PresentPlayCardUI and from within this file

	local color = (newOrderIsOrder and '#FF7D00') or '#FF0000';
	local horz = Horz(parent);

	function label(txt)
		return Label(horz).SetText(txt).SetColor(color);
	end

	HighlightTerrBtn(game, tonumber(cardOrder.ModData), horz);

	if order.proxyType == 'GameOrderPlayCardCustom' then
		return label('already has a ' .. card.Name .. ' played on it');
	end

	if newOrderIsOrder then
		local msg = 'will not be able to send or receive armies from attacks/transfers or airlifts ';

		if isActiveCard then
			msg = msg .. 'due to a previously played ' .. card.Name;
		else
			msg = msg .. 'after the ' .. card.Name .. 'is played';
		end

		msg = msg .. ', making the order you tried to do useless';

		label(msg);
		MakeUnplayCardMsg(parent);

		return;
	end

	local useless = ' from here would become useless if the ' .. card.Name .. ' is played. ';
	local retry = ' then try again, or select a different territory.';

	if order.proxyType == 'GameOrderAttackTransfer' then
		return label('attacks/transfers ' .. useless .. 'Remove attacks/transfers from here' .. retry);
	end

	if order.proxyType == 'GameOrderPlayCardAirlift' then
		label('Airlift Cards' .. useless .. 'Un-play the card' .. retry);
	end

	MakeUnplayCardMsg(parent);
end