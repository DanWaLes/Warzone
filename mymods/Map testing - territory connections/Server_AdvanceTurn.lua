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
		setIncomesToZero(game, addNewOrder);
		return;
	end

	-- todo the actual mod
	-- use optimal number of attacks

	setIncomesToZero(game, addNewOrder);
end

function setIncomesToZero(game, addNewOrder)
	local incomeMods = {};

	for id, player in pairs(game.ServerGame.Game.PlayingPlayers) do
		local income = player.Income(0, game.ServerGame.LatestTurnStanding, false, false).Total;
		print('income for ' .. id .. ' is ' .. income);

		table.insert(incomeMods, WL.IncomeMod.Create(id, -income, 'Removed all income'));
	end

	local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, 'Removed everyones income', nil, nil, nil, incomeMods);
	addNewOrder(event);
end