function terrHasNoArmies(terr)
	-- checks if non-neutral territories have armies

	if terr.IsNeutral then
		return false;
	end

	local hasSpecialUnits = false;

	for _, unit in pairs(terr.NumArmies.SpecialUnits) do
		if unit.OwnerID == terr.OwnerPlayerID then
			hasSpecialUnits = true;
			break;
		end
	end

	return terr.NumArmies.NumArmies == 0 and not hasSpecialUnits;
end