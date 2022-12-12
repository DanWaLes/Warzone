require 'distributionWastelands'
require 'util'

function Server_StartDistribution(game, standing)
	if Mod.Settings.CreateDistributionWastelandsAfterPicks then
		clearWastelands(game, standing);
	else
		makeDistributionWastelands(game, standing);
	end
end

function clearWastelands(game, standing)
	local numWastelands = game.Settings.NumberOfWastelands;

	if numWastelands > 0 then
		local wastelandCount = 0;

		for terrId, territory in pairs(standing.Territories) do
			if territory.IsNeutral and territory.NumArmies.NumArmies == game.Settings.WastelandSize then
				wastelandCount = wastelandCount + 1;

				local size = game.Settings.InitialNonDistributionArmies;-- this is usually correct
				standing.Territories[terrId].NumArmies = WL.Armies.Create(size);

				local distMode = game.Settings.DistributionModeID;
				-- checking if should be pickable would be slow for non-full dist, esp. for bonuses with lots of territories and overlapping bonuses
				local isFullDist = distMode == 0;

				if isFullDist then
					standing.Territories[terrId].OwnerPlayerID = WL.PlayerID.AvailableForDistribution;
				end

				if wastelandCount == numWastelands then
					break;
				end
			end
		end
	end
end