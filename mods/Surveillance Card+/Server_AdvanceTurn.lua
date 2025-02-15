require('settings');
require('tblprint');

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if order.proxyType ~= 'GameOrderPlayCardSurveillance' then
		return;
	end

	print('order.TargetBonus', order.TargetBonus);

	local bonus = game.Map.Bonuses[order.TargetBonus];

	print('type(bonus)', type(bonus));
	print('tblprint(bonus) = ');
	tblprint(bonus);

	local numTerrsInBonus = nil;

	if type(bonus) == 'table' then
		numTerrsInBonus = #bonus.Territories;
	end

	local maxTerrs = getSetting('MaxTerrs');

	print('numTerrsInBonus', numTerrsInBonus);
	print('maxTerrs', maxTerrs)

	if numTerrsInBonus > maxTerrs then
		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);

		local visibleTo = game.Settings.CardPlayingsFogged and {} or nil;

		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, 'Skipped Surveillance Card from being played on ' .. bonus.Name, visibleTo));
	end
end
