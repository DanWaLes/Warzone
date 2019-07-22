-- apply bonus overrider if needed

function Server_Created(game, settings)
	-- print(settings.CommerceArmyCostMultiplier);

	-- apply bonus overrider
    local overriddenBonuses = {};

    for i, bonus in pairs(game.Map.Bonuses) do
		overriddenBonuses[bonus.ID] = bonus.Amount + #bonus.Territories;
	end

    settings.OverriddenBonuses = overriddenBonuses;
end