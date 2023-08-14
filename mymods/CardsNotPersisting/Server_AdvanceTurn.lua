function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if order.proxyType == 'GameOrderCustom' and order.Payload == 'playReconCard' then
		playReconCard(game, order.PlayerID, addNewOrder);
	end
end

function playReconCard(game, playerId, addNewOrder)
	local terrId = nil;
	for tId in pairs(game.Map.Territories) do
		terrId = tId;
		break;
	end

	local reconCard = WL.NoParameterCardInstance.Create(WL.CardID.Reconnaissance);
	local order = WL.GameOrderPlayCardReconnaissance.Create(reconCard.ID, playerId, terrId);
	addNewOrder(order);
end