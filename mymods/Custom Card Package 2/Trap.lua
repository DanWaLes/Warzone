function playCardTrap(game, tabData, cardName, btn, vert, vert2, data)
	if not data.phase then
		data.phase = WL.TurnPhase.Attacks - 1;
	end

	if not data.validateTerrSelection then
		data.validateTerrSelection = function(selectedTerr)
			local terrId = selectedTerr.ID;
			local terr = game.LatestStanding.Territories[terrId];

			return terr.OwnerPlayerID == game.Us.ID;
		end;
	end

	if not data.errMsg then
		data.errMsg = 'You can only play a ' .. cardName .. ' Card on one of your own territories';
	end

	createTerritorySelectionCard(game, tabData, cardName, btn, vert, vert2, data);
end

function playedCardTrap(wz, player, cardName, param)
	local terrId = tonumber(param);
	local terr = wz.game.Map.Territories[terrId];

	if not terr then
		return;
	end

	local event = WL.GameOrderEvent.Create(player.ID, 'Played a ' .. cardName .. ' Card on ' .. terr.Name, {});
	event.JumpToActionSpotOpt = WL.RectangleVM.Create(terr.MiddlePointX, terr.MiddlePointY, 0, 0);

	wz.addNewOrder(event);

	return true;
end

function processStartTurnTrap(game, addNewOrder, cardName)
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

local function doTrapCardEffect(wz, cardName, i, activeCardInstance)
	local targetTerr = wz.order.To;
	local attackedBy = wz.order.PlayerID;
	local playedById = activeCardInstance.playedBy;
	local players = wz.game.ServerGame.Game.Players;
	local isDifferentPlayer = players[attackedBy].Team == -1 and attackedBy ~= playedById;
	local isDifferentTeam = players[attackedBy].Team ~= -1 and players[attackedBy].Team ~= players[playedById].Team;
	local terrName = wz.game.Map.Territories[targetTerr].Name;

	if not (isDifferentPlayer or isDifferentTeam) then
		return;
	end

	local armiesTakingOver = wz.result.ActualArmies.Subtract(wz.result.AttackingArmiesKilled);

	local specialUnitsToRemove = {};
	for _, unit in pairs(armiesTakingOver.SpecialUnits) do
		table.insert(specialUnitsToRemove, unit.ID);
	end

	local mod = WL.TerritoryModification.Create(targetTerr);
	mod.SetOwnerOpt = WL.PlayerID.Neutral;
	mod.SetArmiesTo = armiesTakingOver.NumArmies * getSetting(cardName .. 'Multiplier');
	mod.RemoveSpecialUnitsOpt = specialUnitsToRemove;

	wz.addNewOrder(WL.GameOrderEvent.Create(playedById, 'Trap activated', {}, {mod}));

	removeActiveCardInstance(cardName, i);
end

function processOrderTrap(wz, cardName)
	if wz.order.proxyType ~= 'GameOrderAttackTransfer' then
		return;
	end

	if not (wz.result.IsAttack and wz.result.IsSuccessful) then
		return;
	end

	local i = 1;
	while i < #Mod.PublicGameData.activeCards[cardName] do
		local activeCardInstance = Mod.PublicGameData.activeCards[cardName][i];

		if wz.order.To == tonumber(activeCardInstance.param) then
			doTrapCardEffect(wz, cardName, i, activeCardInstance);
			i = i - 1;
		end

		i = i + 1;
	end	
end