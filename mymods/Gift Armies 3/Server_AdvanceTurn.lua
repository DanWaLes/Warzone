require '_util';
require 'version';
require 'armies';

function print2(addNewOrder, msg)
	print(msg);
	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, msg));
end

local checkedTerrs = {};
local startingSpecialUnitsByTerrs = {};

function Server_AdvanceTurn_Start(game, addNewOrder)
	local publicGD = Mod.PublicGameData;

	if not publicGD then
		publicGD = {};
	end

	if not publicGD.terrsToCheck then
		publicGD.terrsToCheck = {};
	end

	for terrId in pairs(publicGD.terrsToCheck) do
		local terr = game.ServerGame.LatestTurnStanding.Territories[terrId];

		checkedTerrs[terrId] = terr.NumArmies;

		startingSpecialUnitsByTerrs[terrId] = {};
		for _, unit in pairs(terr.NumArmies.SpecialUnits) do
			startingSpecialUnitsByTerrs[terrId][unit.ID] = unit;
		end
	end

	-- print('checkedTerrs = ');
	-- tblprint(checkedTerrs);

	publicGD.terrsToCheck = {};
	Mod.PublicGameData = publicGD;
end

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if game.Settings.SinglePlayer and not canRunMod() then
		return;
	end

	-- print('order.proxyType = ' .. order.proxyType);

	-- keeps track of the amount of armies that are actually usable

	if order.proxyType == 'GameOrderAttackTransfer' then
		if checkedTerrs[order.From] then
			checkedTerrs[order.From] = checkedTerrs[order.From].Subtract(result.ActualArmies);
		elseif checkedTerrs[order.To] and result.IsAttack then
			checkedTerrs[order.To] = checkedTerrs[order.To].Subtract(result.DefendingArmiesKilled);
		end
	elseif order.proxyType == 'GameOrderPlayCardAirlift' then
		if checkedTerrs[order.FromTerritoryID] then
			checkedTerrs[order.FromTerritoryID] = checkedTerrs[order.FromTerritoryID].Subtract(result.ArmiesAirlifted);
		end
	elseif order.proxyType == 'GameOrderPlayCardBomb' then
		if checkedTerrs[order.TargetTerritoryID] then
			local halved = game.ServerGame.LatestTurnStanding.Territories[order.TargetTerritoryID].NumArmies.NumArmies / 2;
			local diff = checkedTerrs[order.TargetTerritoryID].NumArmies - halved;

			if diff < 0 then
				diff = checkedTerrs[order.TargetTerritoryID].NumArmies
			end

			checkedTerrs[order.FromTerritoryID] = checkedTerrs[order.FromTerritoryID].Subtract(WL.Armies.Create(diff));
		end
	elseif order.proxyType == 'GameOrderEvent' or order.proxyType == 'GameOrderBossEvent' then
		local terrMods;

		if order.proxyType == 'GameOrderEvent' then
			terrMods = order.TerritoryModifications;
		else
			terrMods = order.ModifyTerritories;
		end

		if terrMods then
			for _, terrMod in pairs(order.TerritoryModifications) do
				if checkedTerrs[terrMod.TerritoryID] then
					if terrMod.SetArmiesTo then
						if terrMod.SetArmiesTo.NumArmies <= checkedTerrs[terrMod.TerritoryID].NumArmies then
							local diff = checkedTerrs[terrMod.TerritoryID].NumArmies - terrMod.SetArmiesTo.NumArmies;

							if diff < 0 then
								diff = checkedTerrs[terrMod.TerritoryID].NumArmies;
							end

							checkedTerrs[terrMod.TerritoryID] = checkedTerrs[terrMod.TerritoryID].Subtract(WL.Armies.Create(diff));
						end

						local unitsToRemove = {};

						for _, unit in pairs(checkedTerrs.terrMod.TerritoryID) do
							local found = false;

							for _, unit2 in pairs(terrMod.SetArmiesTo.SpecialUnits) do
								if unit.ID == unit2.ID then
									found = true;
									break;
								end
							end

							if not found then
								table.insert(unitsToRemove, unit);
							end
						end

						checkedTerrs[terrMod.TerritoryID] = checkedTerrs[terrMod.TerritoryID].Subtract(WL.Armies.Create(0, unitsToRemove));
					end

					if terrMod.AddArmies and terrMod.AddArmies < 0 then
						checkedTerrs[terrMod.TerritoryID] = checkedTerrs[terrMod.TerritoryID].Subtract(WL.Armies.Create(terrMod.AddArmies));
					end

					if terrMod.RemoveSpecialUnitsOpt then
						for _, unitId in pairs(terrMod.RemoveSpecialUnitsOpt) do
							for _, unit in pairs(checkedTerrs[terrMod.TerritoryID]) do
								if unit.ID == unitId then
									checkedTerrs[terrMod.TerritoryID] = checkedTerrs[terrMod.TerritoryID].Subtract(WL.Armies.Create(0, {unit}));
									break;
								end
							end
						end
					end
				end
			end
		end
	end

	if order.proxyType == 'GameOrderCustom' then
		print("init order.proxyType == 'GameOrderCustom'");
		print('payload = ' .. order.Payload);

		if startsWith(order.Payload, 'giftarmies3_') then
			processGiftArmies3Order(game, order, result, skipThisOrder, addNewOrder);
		end
	end
end

function processGiftArmies3Order(game, order, result, skipThisOrder, addNewOrder)
	print('init processGiftArmies3Order');

	skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);

	local params = split(order.Payload, '_');

	local fromId = tonumber(params[2]);
	local fromTerr = game.ServerGame.LatestTurnStanding.Territories[fromId];
	local fromDetails = game.Map.Territories[fromId];
	local toId = tonumber(params[3]);
	local toTerr = game.ServerGame.LatestTurnStanding.Territories[toId];
	local toDetails = game.Map.Territories[toId];
	local toOwnerExpected = tonumber(params[4]);

	if not checkedTerrs[fromId] then
		print2(addNewOrder, 'Skipped unexpected order with payload ' .. order.Payload);
		return;
	end

	local actionSpot = WL.RectangleVM.Create(fromDetails.MiddlePointX, fromDetails.MiddlePointY, fromDetails.MiddlePointX, fromDetails.MiddlePointY);

	print('checking fromTerr');

	if fromTerr.OwnerPlayerID ~= order.PlayerID then
		local usName = game.Players[order.PlayerID].DisplayName(nil, false);
		local msg = 'Could not ' .. order.Message .. ' because ' .. fromDetails.Name .. ' is no longer owned by ' .. usName;
		local order = WL.GameOrderEvent.Create(order.PlayerID, msg, {order.PlayerID, toOwnerExpected});
		order.JumpToActionSpotOpt = actionSpot;
		addNewOrder(order);
		return;
	end

	print('checked fromTerr');
	print('checking toTerr');

	if toTerr.OwnerPlayerID ~= toOwnerExpected then
		local toName = game.Players[toOwnerExpected].DisplayName(nil, false);
		local msg = 'Could not ' .. order.Message .. ' because ' .. toDetails.Name .. ' is no longer owned by ' .. toName;
		local order = WL.GameOrderEvent.Create(order.PlayerID, msg, {order.PlayerID, toOwnerExpected});
		order.JumpToActionSpotOpt = actionSpot;
		addNewOrder(order);
		return;
	end

	print('checked toTerr');

	-- send as much remaining armies as possible
	local armies = parseArmies(params[5]);
	local orderMsg = order.Message;
	local orderEdited = false;
	local armiesToTransfer = {
		NumArmies = nil,
		specialUnitsToAdd = {},
		specialUnitsToRemove = {}
	};

	print('checking actual armies');

	local movableArmies = checkedTerrs[fromId].NumArmies;

	if movableArmies < 0 then
		movableArmies = 0;
	end

	if game.Settings.OneArmyStandsGuard then
		if fromTerr.NumArmies.NumArmies <= movableArmies then
			movableArmies = movableArmies - 1;
		end
	end

	if movableArmies < 0 then
		movableArmies = 0;
	end

	print('armies = ');
	tblprint(armies);

	print('movableArmies = ');
	tblprint(movableArmies);

	if armies.NumArmies > movableArmies then
		orderEdited = true;
		armiesToTransfer.NumArmies = movableArmies;
	else
		local numArmies = armies.NumArmies;

		if game.Settings.OneArmyStandsGuard then
			if fromTerr.NumArmies.NumArmies <= numArmies then
				orderEdited = true;
				numArmies = numArmies - 1;
			end
		end

		armiesToTransfer.NumArmies = numArmies;
	end

	print('checked actual armies');
	print('checking special units');

	-- see which special units should be moved

	function getMostRecentVersionOfSpecailUnit(unitId)
		for _, unit in pairs(game.ServerGame.LatestTurnStanding.Territories[fromId].NumArmies.SpecialUnits) do
			if unit.ID == unitId then
				return unit;
			end
		end

		return nil;
	end

	local unitsToMove = {};
	local unitsNotFound = {};

	for _, unitToTransferId in pairs(armies.SpecialUnits) do
		print('checking unit ' .. unitToTransferId);

		-- check if the unit was there at the start
		local unitFound = nil;

		for _, unit in pairs(checkedTerrs[fromId].SpecialUnits) do
			unit = getMostRecentVersionOfSpecailUnit(unit.ID);

			if unit.ID == unitToTransferId then
				if unit.proxyType == 'CustomSpecialUnit' then
					-- gifting the unit like this is like a transfer. player transferring to is like a teammate
					if unit.OwnerID == order.PlayerID and unit.CanBeTransferredToTeammate then
						unitFound = unit;
						break;
					else
						orderEdited = true;
						break;
					end
				else
					-- shouldnt be allowed to transfer bosses or commanders
					-- cant clone bosses
					-- each player has a commander, commanders stick to same player

					orderEdited = true;
					break;
				end
			end
		end

		if unitFound then
			print('found ' .. unitToTransferId);

			unitsToMove[unitFound.ID] = unitFound;
			table.insert(armiesToTransfer.specialUnitsToRemove, unitFound.ID);

			local builder = WL.CustomSpecialUnitBuilder.CreateCopy(unitFound);
			builder.OwnerID = toOwnerExpected;

			table.insert(armiesToTransfer.specialUnitsToAdd, builder.Build());
		else
			print('not found ' .. unitToTransferId);

			orderEdited = true;-- approximate match might have different name

			local startingUnit = startingSpecialUnitsByTerrs[fromId][unitToTransferId];

			if startingUnit then
				if startingUnit.proxyType == 'CustomSpecialUnit' then
					if startingUnit.OwnerID == order.PlayerID and startingUnit.CanBeTransferredToTeammate then
						table.insert(unitsNotFound, startingUnit);
					end
				end
			end
		end
	end


	-- find a unit with approximate match

	for _, unfoundUnit in pairs(unitsNotFound) do
		print('finding approximate match for ' .. unfoundUnit.ID);

		for _, unit in pairs(checkedTerrs[fromId].SpecialUnits) do
			unit = getMostRecentVersionOfSpecailUnit(unit.ID);

			if unit.OwnerID == order.PlayerID and unit.proxyType == 'CustomSpecialUnit' and unit.CanBeTransferredToTeammate and (not unitsToMove[unit.ID]) and unit.ModID == unfoundUnit.ModID and unit.ImageFilename == unfoundUnit.ImageFilename then
				unitsToMove[unit.ID] = true;
				table.insert(armiesToTransfer.specialUnitsToRemove, unit.ID);

				local builder = WL.CustomSpecialUnitBuilder.CreateCopy(unit);
				builder.OwnerID = toOwnerExpected;
				table.insert(armiesToTransfer.specialUnitsToAdd, builder.Build());
				break;
			end
		end
	end

	print('checked special units');

	if orderEdited then
		orderMsg = 'Gift ' .. messagifyArmies(armiesToTransfer) .. ' from ' .. fromDetails.Name .. ' to ' .. toDetails.Name .. '\r\nOriginal order: ' .. orderMsg;
	end

	print('about to make fromMod');
	local fromMod = WL.TerritoryModification.Create(fromId);
	fromMod.AddArmies = -armiesToTransfer.NumArmies;
	fromMod.RemoveSpecialUnitsOpt = armiesToTransfer.specialUnitsToRemove;
	print('made fromMod');

	print('about to make toMod');
	print('toId = ' .. toId);
	-- print('armiesToTransfer = ');
	-- tblprint(armiesToTransfer);

	local toMod = WL.TerritoryModification.Create(toId);

	print('about to set toMod.AddArmies');
	toMod.AddArmies = armiesToTransfer.NumArmies;
	print('set toMod.AddArmies');

	print('about to set toMod.AddSpecialUnits');
	toMod.AddSpecialUnits = armiesToTransfer.specialUnitsToAdd;
	print('set toMod.AddSpecialUnits')

	print('made toMod');

	local order = WL.GameOrderEvent.Create(order.PlayerID, orderMsg, {}, {fromMod, toMod});
	order.JumpToActionSpotOpt = actionSpot;

	addNewOrder(order);
	tblprint(order);
end