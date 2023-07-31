-- first turn cancel all deployments

-- mod
-- set income to 0

local doneSkippingTurn1 = false;

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder)
	if game.ServerGame.Game.TurnNumber == 1 and not doneSkippingTurn1 then
		-- -- if turn 1 prevent all orders - get income from bonuses and no income mod turn before
		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
	end
	print('made it here');

	-- if player attacks between same territories skip first A cant attack B but B can attack A
end

function Server_AdvanceTurn_End(game, addNewOrder)
	doneSkippingTurn1 = true;

	if game.ServerGame.Game.TurnNumber == 1 then
		setIncomesToZero(game, addNewOrder);
		return;
	end

	setIncomesToZero(game, addNewOrder);
end

function setIncomesToZero(game, addNewOrder)
	local incomeMods = {};

	for id, player in pairs(game.ServerGame.Game.PlayingPlayers) do
		local income = player.Income(0, game.ServerGame.LatestTurnStanding, false, false).Total;

		table.insert(incomeMods, WL.IncomeMod.Create(id, -income, 'Removed all income'));
	end

	print('about to add order');
	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, 'Removed everyones income', {}, nil, nil, incomeMods));
end