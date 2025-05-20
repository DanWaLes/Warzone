require "Util"

-- force-enable commerce if needed and apply bonus overrider if needed

function Server_Created(game, settings)
	print("init Server_Created");
	-- print(settings.CommerceArmyCostMultiplier); is 0 to treat Gold just like armies
	if not settings.CommerceGame then
		settings.CommerceArmyCostMultiplier = 0;
		print("force enabled commerce");
	end

	-- apply bonus overrider
	if Mod.Settings.EnableBonusOverrider and Mod.Settings.Gold > 0 then
		local overriddenBonuses = {};

		for i, bonus in pairs(game.Map.Bonuses) do
			overriddenBonuses[bonus.ID] = bonus.Amount + round((#bonus.Territories / Mod.Settings.Territories) * Mod.Settings.Gold);
		end

		settings.OverriddenBonuses = overriddenBonuses;
	end

	local publicGameData = Mod.PublicGameData;-- can be read by client

	publicGameData.enteredServer_StartGame = false;
	Mod.PublicGameData = publicGameData;
end