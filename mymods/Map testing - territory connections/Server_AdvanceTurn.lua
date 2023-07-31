-- first turn cancel all deployments

-- mod
-- set income to 0

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder)
	print('Turn number = ');
	print(game.ServerGame.Game.TurnNumber);

	-- if turn 1 prevent all orders - get income from bonuses and no income mod turn before
	-- if player attacks between same territories skip first A cant attack B but B can attack A
end

function Server_AdvanceTurn_End(game, addNewOrder)
	
end