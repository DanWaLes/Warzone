require 'util';

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if order.proxyType == 'GameOrderCustom' and order.payload == 'OrderNotes' then
		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage)
	end
end