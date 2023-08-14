function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	if not game.Us or game.Us.State ~= WL.GamePlayerState.Playing then
		return;
	end

	setMaxSize(400, 200);

	local order = WL.GameOrderCustom.Create(game.Us.ID, 'Play recon card', 'playReconCard', nil, WL.TurnPhase.SpyingCards);
	placeOrderInCorrectPosition(game, order);
	close();
end

function placeOrderInCorrectPosition(clientGame, newOrder)
	if not newOrder.OccursInPhase then
		local orders = clientGame.Orders;
		table.insert(orders, newOrder);
		clientGame.Orders = orders;
	else
		local orders = {};
		local addedNewOrder = false;

		for _, order in pairs(clientGame.Orders) do
			if order.OccursInPhase then
				if not addedNewOrder and order.OccursInPhase > newOrder.OccursInPhase then
					table.insert(orders, newOrder);
					addedNewOrder = true;;
				end

				table.insert(orders, order);
			else
				table.insert(orders, order);
			end
		end

		if not addedNewOrder then
			table.insert(orders, newOrder);
		end

		clientGame.Orders = orders;
	end
end