function playCardReconnaissance(game, tabData, cardName, btn, vert, vert2, data)
	if not data.phase then
		data.phase = WL.TurnPhase.SpyingCards;
	end

	if not data.validateTerrSelection then
		data.validateTerrSelection = function(selectedTerr)
			return true;
		end;
	end

	if not data.errMsg then
		data.errMsg = '';
	end

	createTerritorySelectionCard(game, tabData, cardName, btn, vert, vert2, data);
end

function playedCardReconnaissance(wz, player, cardName, param)
	if not wz.game.Settings.Cards or not wz.game.Settings.Cards[WL.CardID.Reconnaissance] then
		return;
	end

	local startTerrId = tonumber(param);
	local startTerr = wz.game.Map.Territories[startTerrId];

	if not startTerr then
		return;
	end

	local event = WL.GameOrderEvent.Create(player.ID, 'Played a ' .. cardName .. ' Card on ' .. startTerr.Name, {});
	event.JumpToActionSpotOpt = WL.RectangleVM.Create(terr.MiddlePointX, terr.MiddlePointY, 0, 0);

	wz.addNewOrder(event);

	local range = getSetting(cardName .. 'Range');
	local doneTerrs = {};

	function main(i, terrIds)
		if i == range then
			return;
		end

		local nextTerrs = {};
		for _, terrId in pairs(terrIds) do
			if not doneTerrs[terrId] then
				local reconCard = WL.NoParameterCardInstance.Create(WL.CardID.Reconnaissance);
				local order = WL.GameOrderPlayCardReconnaissance.Create(reconCard.ID, player.ID, terrId);

				wz.addNewOrder(order);

				if i + 1 < range then
					local terr = wz.game.Map.Territories[terrId];

					for connectedTo in pairs(terr.ConnectedTo) do
						table.insert(nextTerrs, connectedTo);
					end
				end

				doneTerrs[terrId] = true;
			end
		end

		main(i + 1, nextTerrs);
	end

	main(0, {startTerrId});

	return true;
end