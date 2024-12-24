function eliminate(playerIds, territories)
	local mods = {};

	for tId, territory in pairs(territories) do
		for _, playerId in pairs(playerIds) do
			if territory.OwnerPlayerID == playerId then
				local mod = WL.TerritoryModification.Create(territory.ID);
				local specialUnitsToRemove = {};

				for _, su in pairs(territory.NumArmies.SpecialUnits) do
					table.insert(specialUnitsToRemove, su.ID);
				end

				mod.RemoveSpecialUnitsOpt = specialUnitsToRemove;
				mod.SetOwnerOpt = WL.PlayerID.Neutral;

				table.insert(mods, mod);
			end
		end
	end

	return mods;
end