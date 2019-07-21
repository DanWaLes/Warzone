-- modify bonuses to be the old value + number of territories in the bonus

function Server_Created(game, settings)
    local overriddenBonuses = {};

    for i, bonus in pairs(game.Map.Bonuses) do
		overriddenBonuses[bonus.ID] = bonus.Amount + #bonus.Territories;
	end

    settings.OverriddenBonuses = overriddenBonuses;
end