require 'runtimeWastelands';

local payload = 'Wastelands+_ServerAdvanceTurnEnd';
local executed = false;

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if order.proxyType == 'GameOrderCustom' and order.Payload == payload then
		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);

		if not executed then
			makeRuntimeWastelands(game, addNewOrder);
			executed = true;
		end
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	addNewOrder(WL.GameOrderCustom.Create(WL.PlayerID.Neutral, '', payload));
end