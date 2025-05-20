function fromTerr1ToTerr2(game, fromTerrId, toTerrId, canTravelOnTerr)
	--[[
		@param game Game
		@param fromTerrId TerritoryID
		@param toTerrId TerritoryID
		@param canTravelOnTerr boolean function(TerritoryID terrId)
		@returns Array<TerritoryID> from fromTerrId to toTerrId
	]]

	if not game.Map.Territories[fromTerrId] then
		print('fromTerr1ToTerr2: fromTerrId not found');
		return;
	end

	if not game.Map.Territories[toTerrId] then
		print('fromTerr1ToTerr2: toTerrId not found');
		return;
	end

	if type(canTravelOnTerr) ~= 'function' then
		print('fromTerr1ToTerr2: canTravelOnTerr must be a function that takes a TerritoryID and returns a boolean');
		return;
	end

	if fromTerrId == toTerrId then
		return {toTerrId};
	end

	local visited = {};-- prevent visiting territories while in same branch of a path
	local shortestPath = nil;
	local stack = {{fromTerrId, {fromTerrId}}};

	while #stack > 0 do
		local currentItem = table.remove(stack);
		local currentTerrId = currentItem[1];
		local currentPath = currentItem[2];

		if not (shortestPath and ((#currentPath + 1) >= #shortestPath)) then
			local currentTerr = game.Map.Territories[currentTerrId];

			if currentTerr.ConnectedTo[toTerrId] then
				table.insert(currentPath, toTerrId);
				shortestPath = currentPath;
				visited = {};
			else
				for terrId in pairs(currentTerr.ConnectedTo) do
					if not visited[terrId] and canTravelOnTerr(terrId) then
						visited[terrId] = true;
						local newPath = clone(currentPath);

						table.insert(newPath, terrId);
						table.insert(stack, {terrId, newPath});
					end
				end
			end
		end
	end

	return shortestPath;
end

function clone(tbl)
	if type(tbl) ~= 'table' or not tbl then
		return tbl;
	end

	local ret = {};

	for k, v in pairs(tbl) do
		ret[k] = clone(v);
	end

	return ret;
end