require '_util';

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	local isAttackTransfer = order.proxyType == 'GameOrderAttackTransfer';
	local isAirlift = order.proxyType == 'GameOrderPlayCardAirlift';

	if not (isAttackTransfer or isAirlift) then
		return;
	end

	if #order.NumArmies.SpecialUnits < 1 then
		return;
	end

	local commanders = {};
	for _, unit in pairs(order.NumArmies.SpecialUnits) do
		if unit.proxyType == 'Commander' then
			table.insert(commanders, unit);
		end
	end

	if #commanders < 1 then
		return;
	end

	if game.Settings.NoSplit then
		-- if it is no split mode and game has commanders and each player has 1 territory then the game cant progress
		-- so lets make sure it can progress before skipping orders

		local playerOwnedTerrs = {};
		local canSkip = false;
		for _, territory in pairs(game.ServerGame.LatestTurnStanding.Territories) do
			if not territory.IsNeutral then
				if not playerOwnedTerrs[territory.OwnerPlayerID] then
					playerOwnedTerrs[territory.OwnerPlayerID] = 0;
				end

				playerOwnedTerrs[territory.OwnerPlayerID] = playerOwnedTerrs[territory.OwnerPlayerID] + 1;

				if playerOwnedTerrs[territory.OwnerPlayerID] > 1 then
					canSkip = true;
					break;
				end
			end
		end

		if canSkip then
			skipThisOrder(WL.ModOrderControl.Skip);
			-- dont recreate the order because its no split mode
		end
	else
		local numArmies = order[(isAirlift and 'Armies' or 'NumArmies')].Subtract(WL.Armies.Create(0, commanders));
		local newOrder = nil;

		if isAttackTransfer then
			newOrder = WL.GameOrderAttackTransfer.Create(order.PlayerID, order.From, order.To, order.AttackTransfer, order.ByPercent, numArmies, order.AttackTeammates);
		elseif isAirlift then
			newOrder = WL.GameOrderPlayCardAirlift.Create(order.CardInstanceID, order.PlayerID, order.From, order.To, numArmies);
		end

		skipThisOrder(WL.ModOrderControl.Skip);
		addNewOrder(newOrder);
	end
end