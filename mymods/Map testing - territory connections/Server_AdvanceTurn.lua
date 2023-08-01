require '_util';

local doneSkippingTurn1 = false;

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder)
	if game.ServerGame.Game.TurnNumber == 1 and not doneSkippingTurn1 then
		-- if turn 1 prevent all orders - get income from bonuses and no income mod turn before
		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
		return;
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	if game.ServerGame.Game.TurnNumber == 1 then
		doneSkippingTurn1 = true;
		setTurn1IncomesToZero(game, addNewOrder);
		return;
	end

	-- todo the actual mod

	local playerOwnedTerrs = setupNextTurn(game, addNewOrder);
	setIncomesToZero(game, addNewOrder, playerOwnedTerrs);
end

function setTurn1IncomesToZero(game, addNewOrder)
	local incomeMods = {};

	for id, player in pairs(game.ServerGame.Game.PlayingPlayers) do
		local income = player.Income(0, game.ServerGame.LatestTurnStanding, false, false).Total;

		table.insert(incomeMods, WL.IncomeMod.Create(id, -income, 'Removed all income'));
	end

	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, 'Removed everyones income', nil, nil, nil, incomeMods));
end

function setIncomesToZero(game, addNewOrder, playerOwnedTerrs)
	-- LatestTurnStanding doesnt update in time after terr mods are made
	local incomeMods = {};

	for playerId, terrId in pairs(playerOwnedTerrs) do
		local income = 0;
		local terr = game.Map.Territories[terrId];

		-- small chance 1 territory could be in a lot of bonuses of itself
		for _, bonusId in pairs(terr.PartOfBonuses) do
			local bonus = game.Map.Bonuses[bonusId];

			if #bonus.Territories == 1 then
				if game.Settings.OverriddenBonuses[bonusId] then
					income = income + game.Settings.OverriddenBonuses[bonusId];
				else
					income = income + bonus.Amount;
				end
			end
		end

		if income > 0 then
			table.insert(incomeMods, WL.IncomeMod.Create(playerId, -income, 'Removed all income'));
		end
	end

	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, 'Removed everyones income', nil, nil, nil, incomeMods));
end

function setupNextTurn(game, addNewOrder)
	print('in setupNextTurn');
	local mods = {};

	for terrId, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		local numSpecialUnits = #terr.NumArmies.SpecialUnits;

		if numSpecialUnits > 0 or terr.NumArmies.NumArmies ~= 0 or not terr.IsNeutral then
			-- so that only territories that need changing are changed
			local mod = WL.TerritoryModification.Create(terrId);

			mod.SetArmiesTo = 0;
			mod.SetOwnerOpt = WL.PlayerID.Neutral;

			if numSpecialUnits > 0 then
				-- only happens if another mod is enabled - no other mod should be enabled
				local specialUnitsToRemove = {};

				for _, unit in pairs(terr.NumArmies.SpecialUnits) do
					table.insert(specialUnitsToRemove, unit.ID);
				end

				mod.RemoveSpecialUnitsOpt = specialUnitsToRemove;
			end

			table.insert(mods, mod);
		end
	end

	local playerOwnedTerrs = {};
	local terrNo = Mod.PublicGameData.terrNo;
	local numTerrs = #Mod.PublicGameData.terrNames;

	for playerId in pairs(game.ServerGame.Game.PlayingPlayers) do
		if terrNo > numTerrs then
			break;
		end

		local terrId = Mod.PublicGameData.terrNames[terrNo].id;
		local mod = WL.TerritoryModification.Create(terrId);

		mod.SetOwnerOpt = playerId;
		table.insert(mods, mod);
		playerOwnedTerrs[playerId] = terrId;
		terrNo = terrNo + 1;
	end

	Mod.PublicGameData.terrNo = terrNo;
	print('about to make Setup next turn order')

	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, 'Setup next turn', nil, mods));
	return playerOwnedTerrs;
end