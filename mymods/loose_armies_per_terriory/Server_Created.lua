-- force enable commerce and apply bonus overrider if needed

function Server_Created(game, settings)
	-- force enable commerce
	if not settings.CommerceGame then
		settings.CommerceGame = true;
		settings.CommerceArmyCostMultiplier = 1;
		settings.CommerceCityBaseCost = nil;
	end

	-- apply bonus overrider
    local overriddenBonuses = {};

    for i, bonus in pairs(game.Map.Bonuses) do
		overriddenBonuses[bonus.ID] = bonus.Amount + #bonus.Territories;
	end

    settings.OverriddenBonuses = overriddenBonuses;
end